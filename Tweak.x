#import "Tweak.h"
#import "SCView.h"

SCView *shortcutView;
UIStackView *stack;

SBIconView* getIconView(NSString *identifier) {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	SBIconView *iconView = [[[%c(SBIconController) sharedInstance] homescreenIconViewMap] extraIconViewForIcon:icon];
	return iconView;
}

void setupShortcutView() {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGRect frame = CGRectMake(bounds.size.width, bounds.size.height / 4, 80, bounds.size.height / 2);
	shortcutView = [[%c(SCView) alloc] initWithFrame:frame];
	stack = [[UIStackView alloc] init];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.distribution = UIStackViewDistributionFillEqually;
	stack.alignment = UIStackViewAlignmentCenter;
	stack.spacing = 20;

	SBIconView *iconView = getIconView(@"com.apple.mobilesafari");
	[stack addArrangedSubview:iconView];
	[iconView.centerXAnchor constraintEqualToAnchor:stack.centerXAnchor].active = true;
	//iconView.center = CGPointMake(shortcutView.frame.size.width / 2, iconView.center.y + 10);

	stack.translatesAutoresizingMaskIntoConstraints = false;
	[shortcutView addSubview:stack];

	[stack.centerXAnchor constraintEqualToAnchor:shortcutView.centerXAnchor].active = true;
    [stack.centerYAnchor constraintEqualToAnchor:shortcutView.centerYAnchor].active = true;
}

%hook SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	UIPress *press = arg1.allPresses.anyObject;
	if (press.type == 102 && press.force == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test.showview" object:nil];
	}
	else if (press.type == 103 && press.force == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test.hideview" object:nil];
	}
	return %orig;
}
%end

%hook SBHomeScreenViewController
%property (nonatomic, assign) BOOL viewIsVisible;

- (void)viewDidLoad {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView) name:@"com.kef.test.showview" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:@"com.kef.test.hideview" object:nil];
}

%new
- (void)showView {
	if (self.viewIsVisible)
		return;

	if (shortcutView == nil) {
		setupShortcutView();
	}

	self.viewIsVisible = YES;
	[self.view addSubview:shortcutView];
	CGRect frame = shortcutView.frame;
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseOut
		animations:^ {
			shortcutView.frame = CGRectMake(frame.origin.x - 80, frame.origin.y, frame.size.width, frame.size.height);
		} completion:nil];
}

%new
- (void)hideView {
	if (!self.viewIsVisible)
		return;

	self.viewIsVisible = NO;
	NSLog(@"self.shortcutView = %@", shortcutView);
	CGRect frame = shortcutView.frame;
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^ {
			shortcutView.frame = CGRectMake(frame.origin.x + 80, frame.origin.y, frame.size.width, frame.size.height);
		} completion:^ (BOOL finished) {
			[shortcutView removeFromSuperview];
		}];
}
%end

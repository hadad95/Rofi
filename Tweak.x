#import "Tweak.h"
#import "SCView.h"
#import "SCViewIconViewController.h"

SCView *shortcutView;
UIStackView *stack;

SBIconView* getIconView(NSString *identifier) {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	SBIconView *iconView = [[[%c(SBIconController) sharedInstance] homescreenIconViewMap] extraIconViewForIcon:icon];
	iconView.delegate = [%c(SCViewIconViewController) sharedInstance];
	return iconView;
}

void setupShortcutView() {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGRect frame = CGRectMake(bounds.size.width, bounds.size.height / 4, 80, bounds.size.height / 2);
	//CGRect stackFrame = CGRectMake(0, 0, 80, bounds.size.height / 2);
	shortcutView = [[%c(SCView) alloc] initWithFrame:frame];
	stack = [[UIStackView alloc] init];
	stack.axis = UILayoutConstraintAxisVertical;
	stack.distribution = UIStackViewDistributionFillProportionally;
	stack.alignment = UIStackViewAlignmentCenter;
	stack.spacing = 10;
	stack.backgroundColor = UIColor.redColor;

	SBIconView *iconView = getIconView(@"com.apple.mobilesafari");
	CGFloat iconWidth = iconView.frame.size.width;
	CGFloat iconHeight = iconView.frame.size.height;
	NSLog(@"iconView.frame = %@", NSStringFromCGRect(iconView.frame));

	stack.translatesAutoresizingMaskIntoConstraints = false;
	[shortcutView addSubview:stack];

	[stack.centerXAnchor constraintEqualToAnchor:shortcutView.centerXAnchor].active = true;
    [stack.centerYAnchor constraintEqualToAnchor:shortcutView.centerYAnchor].active = true;
    //[stack.leadingAnchor constraintEqualToAnchor:shortcutView.leadingAnchor].active = true;
    [stack.widthAnchor constraintGreaterThanOrEqualToAnchor:shortcutView.widthAnchor].active = true;
    [stack.heightAnchor constraintGreaterThanOrEqualToAnchor:shortcutView.heightAnchor].active = true;

    [stack addArrangedSubview:iconView];
    [iconView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
    NSLog(@"width = %f, height = %f", iconWidth, iconHeight);
    
    SBIconView *iconView2 = getIconView(@"com.apple.Preferences");
    [stack addArrangedSubview:iconView2];
    [iconView2.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView2.heightAnchor constraintEqualToConstant:iconHeight].active = true;

    
    SBIconView *iconView3 = getIconView(@"com.apple.mobileslideshow");
    [stack addArrangedSubview:iconView3];
    [iconView3.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView3.heightAnchor constraintEqualToConstant:iconHeight].active = true;
    
}

%hook SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	UIPress *press = arg1.allPresses.anyObject;
	if (press.type == 102 && press.force == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test/showview" object:nil];
	}
	else if (press.type == 103 && press.force == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test/hideview" object:nil];
	}
	return %orig;
}
%end

%hook SBHomeScreenViewController
%property (nonatomic, assign) BOOL viewIsVisible;

- (void)viewDidLoad {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView) name:@"com.kef.test/showview" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:@"com.kef.test/hideview" object:nil];
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

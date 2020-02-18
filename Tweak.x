#import "Tweak.h"
#import "SCView.h"
#import "SCViewIconViewController.h"

SCView *shortcutView;
UIStackView *shortcutStackView;

SBIconView* getIconView(NSString *identifier) {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	SBIconView *iconView = [[[%c(SBIconController) sharedInstance] homescreenIconViewMap] extraIconViewForIcon:icon];
	iconView.delegate = [%c(SCViewIconViewController) sharedInstance];
	return iconView;
}

void addIconViewToStackView(NSString *identifier, UIStackView *stackView) {
	SBIconView *iconView = getIconView(identifier);
	CGFloat iconWidth = iconView.frame.size.width;
	CGFloat iconHeight = iconView.frame.size.height;
	[stackView addArrangedSubview:iconView];
	[iconView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
}

void setupShortcutView() {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGRect frame = CGRectMake(bounds.size.width, bounds.size.height / 10, 80, bounds.size.height * 8 / 10);
	shortcutView = [[%c(SCView) alloc] initWithFrame:frame];
	shortcutStackView = [[UIStackView alloc] init];
	shortcutStackView.axis = UILayoutConstraintAxisVertical;
	shortcutStackView.distribution = UIStackViewDistributionFillProportionally;
	shortcutStackView.alignment = UIStackViewAlignmentCenter;
	shortcutStackView.spacing = 10;
	shortcutStackView.layoutMarginsRelativeArrangement = YES;
	shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 10, 0);

	shortcutStackView.translatesAutoresizingMaskIntoConstraints = false;
	[shortcutView addSubview:shortcutStackView];

	[shortcutStackView.centerXAnchor constraintEqualToAnchor:shortcutView.centerXAnchor].active = true;
    [shortcutStackView.centerYAnchor constraintEqualToAnchor:shortcutView.centerYAnchor].active = true;
    [shortcutStackView.widthAnchor constraintGreaterThanOrEqualToAnchor:shortcutView.widthAnchor].active = true;
    [shortcutStackView.heightAnchor constraintGreaterThanOrEqualToAnchor:shortcutView.heightAnchor].active = true;

    addIconViewToStackView(@"com.apple.mobilesafari", shortcutStackView);
    addIconViewToStackView(@"com.apple.Preferences", shortcutStackView);
    addIconViewToStackView(@"com.apple.mobileslideshow", shortcutStackView);
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

#import "Tweak.h"
#import "SCView.h"

SCView *shortcutView;
UIStackView *shortcutStackView;
UIScrollView *shortcutScrollView;
UIVisualEffectView *blurView;

SBIconView* getIconView(NSString *identifier, SBHomeScreenViewController *controller) {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	SBIconView *iconView = [[[%c(SBIconController) sharedInstance] homescreenIconViewMap] extraIconViewForIcon:icon];
	iconView.delegate = controller;
	return iconView;
}

void addIconViewToStackView(NSString *identifier, UIStackView *stackView, SBHomeScreenViewController *controller) {
	SBIconView *iconView = getIconView(identifier, controller);
	CGFloat iconWidth = iconView.frame.size.width;
	CGFloat iconHeight = iconView.frame.size.height;
	[stackView addArrangedSubview:iconView];
	[iconView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
}

void setupShortcutView(SBHomeScreenViewController *controller) {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGRect frame = CGRectMake(bounds.size.width, bounds.size.height / 4, 80, bounds.size.height / 2);
	shortcutView = [[%c(SCView) alloc] initWithFrame:frame];
	shortcutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 80, bounds.size.height / 2)];
	shortcutScrollView.translatesAutoresizingMaskIntoConstraints = false;
	shortcutScrollView.showsVerticalScrollIndicator = NO;

	blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
	blurView.frame = controller.view.bounds;

	shortcutStackView = [[UIStackView alloc] init];
	shortcutStackView.axis = UILayoutConstraintAxisVertical;
	shortcutStackView.distribution = UIStackViewDistributionFillProportionally;
	shortcutStackView.alignment = UIStackViewAlignmentCenter;
	shortcutStackView.spacing = 20;
	shortcutStackView.layoutMarginsRelativeArrangement = YES;
	shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 20, 0);

	shortcutStackView.translatesAutoresizingMaskIntoConstraints = false;
	[shortcutScrollView addSubview:shortcutStackView];
	[shortcutView addSubview:shortcutScrollView];
	//[blurView addSubview:shortcutView];

	[shortcutScrollView.leadingAnchor constraintEqualToAnchor:shortcutView.leadingAnchor].active = true;
    [shortcutScrollView.trailingAnchor constraintEqualToAnchor:shortcutView.trailingAnchor].active = true;
    [shortcutScrollView.topAnchor constraintEqualToAnchor:shortcutView.topAnchor].active = true;
    [shortcutScrollView.bottomAnchor constraintEqualToAnchor:shortcutView.bottomAnchor].active = true;

    [shortcutStackView.centerXAnchor constraintEqualToAnchor:shortcutScrollView.centerXAnchor].active = true;
    //[shortcutStackView.trailingAnchor constraintEqualToAnchor:shortcutScrollView.trailingAnchor].active = true;
    [shortcutStackView.topAnchor constraintEqualToAnchor:shortcutScrollView.topAnchor].active = true;
    [shortcutStackView.bottomAnchor constraintEqualToAnchor:shortcutScrollView.bottomAnchor].active = true;

    addIconViewToStackView(@"com.apple.mobilesafari", shortcutStackView, controller);
    addIconViewToStackView(@"com.apple.Preferences", shortcutStackView, controller);
    addIconViewToStackView(@"com.apple.mobileslideshow", shortcutStackView, controller);
    addIconViewToStackView(@"com.apple.Maps", shortcutStackView, controller);
    addIconViewToStackView(@"com.hammerandchisel.discord", shortcutStackView, controller);
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
		setupShortcutView(self);
	}

	self.viewIsVisible = YES;
	[shortcutScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
	[self.view addSubview:blurView];
	[self.view addSubview:shortcutView];
	CGRect frame = shortcutView.frame;
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseOut
		animations: ^ {
			blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		} completion:nil];
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
			blurView.effect = nil;
		} completion:nil];
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^ {
			shortcutView.frame = CGRectMake(frame.origin.x + 80, frame.origin.y, frame.size.width, frame.size.height);
		} completion:^ (BOOL finished) {
			[shortcutView removeFromSuperview];
			[blurView removeFromSuperview];
		}];
}

%new
-(void)iconTapped:(id)arg1 {
	[self hideView];
	NSString *bundleID = [((SBIconView *)arg1).icon applicationBundleID];
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}
%end

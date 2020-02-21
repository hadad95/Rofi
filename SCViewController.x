#import "SCViewController.h"
#import "SCView.h"
#import "Tweak.h"

@implementation SCViewController

- (BOOL)shouldAutorotate {
	return NO;
}

- (SBIconView*)getIconView:(NSString *)identifier {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	SBIconView *iconView = [[((SBIconController *)[%c(SBIconController) sharedInstance]) homescreenIconViewMap] extraIconViewForIcon:icon];
	iconView.delegate = self;
	return iconView;
}

- (void)addIconViewToStackView:(NSString *)identifier {
	SBIconView *iconView = [self getIconView:identifier];
	CGFloat iconWidth = iconView.frame.size.width;
	CGFloat iconHeight = iconView.frame.size.height;
	[self.shortcutStackView addArrangedSubview:iconView];
	[iconView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView) name:@"com.kef.test/showview" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:@"com.kef.test/hideview" object:nil];
	[UIApplication.sharedApplication performSelector:@selector(addActiveOrientationObserver:) withObject:self];

	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGFloat ratio = 0.5;
	CGRect frame = CGRectMake(bounds.size.width, bounds.size.height * (1 - ratio) / 2, 80, bounds.size.height * ratio);
	self.shortcutView = [((SCView *)[%c(SCView) alloc]) initWithFrame:frame];
	self.shortcutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 80, bounds.size.height / 2)];
	self.shortcutScrollView.translatesAutoresizingMaskIntoConstraints = false;
	self.shortcutScrollView.showsVerticalScrollIndicator = NO;

	self.blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
	self.blurView.frame = self.view.bounds;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewTapped:)];
	[self.blurView addGestureRecognizer:tapRecognizer];

	self.shortcutStackView = [[UIStackView alloc] init];
	self.shortcutStackView.axis = UILayoutConstraintAxisVertical;
	self.shortcutStackView.distribution = UIStackViewDistributionFillProportionally;
	self.shortcutStackView.alignment = UIStackViewAlignmentCenter;
	self.shortcutStackView.spacing = 20;
	self.shortcutStackView.layoutMarginsRelativeArrangement = YES;
	self.shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(0, 0, 20, 0);

	self.shortcutStackView.translatesAutoresizingMaskIntoConstraints = false;
	[self.shortcutScrollView addSubview:self.shortcutStackView];
	[self.shortcutView addSubview:self.shortcutScrollView];

	[self.shortcutScrollView.leadingAnchor constraintEqualToAnchor:self.shortcutView.leadingAnchor].active = true;
    [self.shortcutScrollView.trailingAnchor constraintEqualToAnchor:self.shortcutView.trailingAnchor].active = true;
    [self.shortcutScrollView.topAnchor constraintEqualToAnchor:self.shortcutView.topAnchor].active = true;
    [self.shortcutScrollView.bottomAnchor constraintEqualToAnchor:self.shortcutView.bottomAnchor].active = true;

    [self.shortcutStackView.centerXAnchor constraintEqualToAnchor:self.shortcutScrollView.centerXAnchor].active = true;
    [self.shortcutStackView.topAnchor constraintEqualToAnchor:self.shortcutScrollView.topAnchor].active = true;
    [self.shortcutStackView.bottomAnchor constraintEqualToAnchor:self.shortcutScrollView.bottomAnchor].active = true;

    [self addIconViewToStackView:@"com.apple.mobilesafari"];
    [self addIconViewToStackView:@"com.apple.Preferences"];
    [self addIconViewToStackView:@"com.apple.mobileslideshow"];
    [self addIconViewToStackView:@"com.apple.Maps"];
    [self addIconViewToStackView:@"com.hammerandchisel.discord"];
}

- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture {
	NSLog(@"handlePan called. gesture.state = %ld", gesture.state);
	//CGPoint translation =  [gesture translationInView:gesture.view];
    CGFloat width = self.shortcutView.frame.size.width;
    CGFloat percent = MAX(-[gesture translationInView:gesture.view ].x, 0)/width;
    if (gesture.state == UIGestureRecognizerStateEnded) {
    	if (percent >= 0.5)
    		[self showView];
    }
}

- (void)showView {
	NSLog(@"showView called");
	if (self.viewIsVisible)
		return;

	self.viewIsVisible = YES;
	[self.shortcutScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
	[self.view addSubview:self.blurView];
	[self.view addSubview:self.shortcutView];
	CGRect frame = self.shortcutView.frame;
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseOut
		animations: ^ {
			self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		} completion:nil];
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseOut
		animations:^ {
			self.shortcutView.frame = CGRectMake(frame.origin.x - 80, frame.origin.y, frame.size.width, frame.size.height);
		} completion:nil];
}

- (void)hideView {
	NSLog(@"hideView called");
	if (!self.viewIsVisible)
		return;

	self.viewIsVisible = NO;
	CGRect frame = self.shortcutView.frame;
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^ {
			self.blurView.effect = nil;
		} completion:nil];
	[UIView animateWithDuration:0.25
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^ {
			self.shortcutView.frame = CGRectMake(frame.origin.x + 80, frame.origin.y, frame.size.width, frame.size.height);
		} completion:^ (BOOL finished) {
			[self.shortcutView removeFromSuperview];
			[self.blurView removeFromSuperview];
		}];
}

-(void)iconTapped:(id)arg1 {
	[self hideView];
	NSString *bundleID = [((SBIconView *)arg1).icon applicationBundleID];
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}

-(void)blurViewTapped:(id)arg1 {
	[self hideView];
}

- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {}

- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1 {}

@end
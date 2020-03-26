#import "RFViewController.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

CGPoint longPressStartingPoint;
UIViewPropertyAnimator *panAnimator;
NSTimer *timeoutTimer;
HBPreferences *prefs;
NSInteger numberOfIcons;
BOOL isRightDirection;
CGFloat barViewCenterYPosition;
NSArray *apps;
BOOL isBarMovable;
BOOL isBarMoving;
CGFloat barWidth;
CGFloat barHeight;
CGFloat barAlpha;
NSString *barColor;
BOOL isTimeoutEnabled;
NSInteger timeoutDelay;

void openApplication(NSString* bundleID)
{
    FBSOpenApplicationOptions* opts = [%c(FBSOpenApplicationOptions) optionsWithDictionary:@{
        @"__LaunchOrigin" : @"BulletinDestinationCoverSheet",
        @"__PromptUnlockDevice" : @YES,
        @"__UnlockDevice" : @YES,
        @"__LaunchImage" : @"",
        @"__Actions" : @[]
    }];
    FBSystemServiceOpenApplicationRequest* request = [%c(FBSystemServiceOpenApplicationRequest) request];
    request.options = opts;
    request.bundleIdentifier = bundleID;
    request.trusted = YES;
    request.clientProcess = [[%c(FBProcessManager) sharedInstance] systemApplicationProcess];

    [[%c(SBMainWorkspace) sharedInstance] systemService:[%c(FBSystemService) sharedInstance] handleOpenApplicationRequest:request withCompletion:^{}];
}

@implementation RFViewController

- (id)init {
	self = [super init];
	if (self) {
		NSLog(@"[RF] width=%f height=%f", barWidth, barHeight);
		self.barViewCornerRadiusSize = (CGSize){10, 10};

		prefs = [HBPreferences preferencesForIdentifier:@"com.kef.rofi"];
		numberOfIcons = [prefs integerForKey:@"numberOfIcons" default:4];
		isRightDirection = [prefs boolForKey:@"isRightDirection" default:YES];
		barViewCenterYPosition = [prefs floatForKey:@"barViewCenterYPosition" default:150];
		apps = (NSArray *)[prefs objectForKey:@"selectedApps" default:[[NSArray alloc] init]];

		[prefs registerBool:&isBarMovable default:YES forKey:@"isBarMovable"];
		[prefs registerFloat:&barWidth default:10.0 forKey:@"barWidth"];
		[prefs registerFloat:&barHeight default:100.0 forKey:@"barHeight"];
		[prefs registerFloat:&barAlpha default:0.5 forKey:@"barAlpha"];
		[prefs registerObject:&barColor default:@"#99AAB5:1.00" forKey:@"barColor"];
		[prefs registerBool:&isTimeoutEnabled default:YES forKey:@"isTimeoutEnabled"];
		[prefs registerInteger:&timeoutDelay default:15 forKey:@"timeoutDelay"];
		[prefs registerPreferenceChangeBlock:^ {
			NSLog(@"[RF] registerPreferenceChangeBlock called");
			CGPoint center;
			CGRect bounds = UIScreen.mainScreen.bounds;
			if (isRightDirection) {
				center = CGPointMake(bounds.size.width - barWidth/2, barViewCenterYPosition);
			}
			else {
				center = CGPointMake(barWidth/2, barViewCenterYPosition);
			}
			UIColor *color = [%c(SparkColourPickerUtils) colourWithString:barColor];
			NSLog(@"[RF] barColor = %@, color = %@", barColor, color);
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.center = center;
					self.barView.transform = CGAffineTransformScale(self.barView.transform, barWidth / self.barView.frame.size.width, barHeight / self.barView.frame.size.height);
					self.barView.backgroundColor = [color colorWithAlphaComponent:barAlpha];
				}];
		}];
	}
	return self;
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (SBIconView*)getIconView:(NSString *)identifier {
	SBIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:identifier];
	if (icon == nil)
		return nil;

	SBIconView *iconView;
	if (SYSTEM_VERSION_LESS_THAN(@"13")) {
		//iconView = [[((SBIconController *)[%c(SBIconController) sharedInstance]) homescreenIconViewMap] extraIconViewForIcon:icon];
		iconView = [[%c(SBIconView) alloc] initWithContentType:0];
		//iconView.delegate = (SBIconController *)[%c(SBIconController) sharedInstance];
	}
	else {
		/*
		NSLog(@"[SC] SBIcon = %@", icon);
		iconView = [[((SBIconController *)[%c(SBIconController) sharedInstance]) iconManager] iconViewForIcon:icon location:@"SBIconLocationRoot"];
		NSLog(@"[SC] iconView = %@", iconView);
		*/
		iconView = [[%c(SBIconView) alloc] initWithConfigurationOptions:0];
		//iconView.delegate = [((SBIconController *)[%c(SBIconController) sharedInstance]) iconManager];
	}
	iconView.icon = icon;
	iconView.delegate = self;
	return iconView;
}

- (void)addIconViewToStackView:(NSString *)identifier {
	SBIconView *iconView = [self getIconView:identifier];
	if (iconView == nil)
		return;

	CGFloat iconWidth = iconView.frame.size.width;
	CGFloat iconHeight = iconView.frame.size.height;
	[self.shortcutStackView addArrangedSubview:iconView];
	[iconView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [iconView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	/*	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView) name:@"com.kef.test/showview" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:@"com.kef.test/hideview" object:nil];
	*/

	//[UIApplication.sharedApplication performSelector:@selector(addActiveOrientationObserver:) withObject:self];

	//isRightDirection = YES;
	//numberOfIcons = 3;

	SBIconView *tempIconView;
	if (SYSTEM_VERSION_LESS_THAN(@"13")) {
		tempIconView = [[%c(SBIconView) alloc] initWithContentType:0];
	}
	else {
		tempIconView = [[%c(SBIconView) alloc] initWithConfigurationOptions:0];
	}

	CGFloat shortcutViewWidth = tempIconView.frame.size.width + 20;
	CGFloat shortcutStackViewSpacing = 20;
	CGFloat shortcutStackViewMarginTop = 10;
	CGFloat shortcutStackViewMarginBottom = 20;
	CGFloat shortcutViewHeight = tempIconView.frame.size.height * numberOfIcons + (numberOfIcons - 1) * shortcutStackViewSpacing + shortcutStackViewMarginTop + shortcutStackViewMarginBottom;

	CGRect bounds = [[UIScreen mainScreen] bounds];
	//CGFloat ratio = 0.7;

	CGRect shortcutViewFrame;
	CAShapeLayer *shortcutViewMaskLayer = [CAShapeLayer layer];
    if (isRightDirection) {
    	shortcutViewFrame = CGRectMake(bounds.size.width, (bounds.size.height - shortcutViewHeight) / 2, shortcutViewWidth, shortcutViewHeight);
    	shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:(CGSize){10.0, 10.0}].CGPath;
    }
    else {
    	shortcutViewFrame = CGRectMake(0 - shortcutViewWidth, (bounds.size.height - shortcutViewHeight) / 2, shortcutViewWidth, shortcutViewHeight);
    	shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){10.0, 10.0}].CGPath;
    }
	self.shortcutView = [[RFView alloc] initWithFrame:shortcutViewFrame];
	self.shortcutView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
	self.shortcutView.layer.mask = shortcutViewMaskLayer;

	self.shortcutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.shortcutView.frame.size.width, self.shortcutView.frame.size.height)];
	self.shortcutScrollView.translatesAutoresizingMaskIntoConstraints = false;
	self.shortcutScrollView.showsVerticalScrollIndicator = NO;
	self.shortcutScrollView.pagingEnabled = YES;
	self.shortcutScrollView.delegate = self;

	self.blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
	self.blurView.frame = self.view.bounds;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewTapped:)];
	[self.blurView addGestureRecognizer:tapRecognizer];

	self.shortcutStackView = [[UIStackView alloc] init];
	self.shortcutStackView.axis = UILayoutConstraintAxisVertical;
	self.shortcutStackView.distribution = UIStackViewDistributionFillProportionally;
	self.shortcutStackView.alignment = UIStackViewAlignmentCenter;
	self.shortcutStackView.spacing = shortcutStackViewSpacing;
	self.shortcutStackView.layoutMarginsRelativeArrangement = YES;
	self.shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(shortcutStackViewMarginTop, 0, shortcutStackViewMarginBottom, 0);

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

    for (NSString *app in apps) {
    	[self addIconViewToStackView:app];
    }

    CGRect barViewFrame;
    CAShapeLayer *barViewMaskLayer = [CAShapeLayer layer];
    NSLog(@"[RF] barViewCenterYPosition = %f", barViewCenterYPosition);
    if (isRightDirection) {
    	barViewFrame = CGRectMake(bounds.size.width - barWidth, barViewCenterYPosition - barHeight/2, barWidth, barHeight);
    	barViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, barWidth, barHeight) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:self.barViewCornerRadiusSize].CGPath;
    }
    else {
    	barViewFrame = CGRectMake(0, barViewCenterYPosition - barHeight/2, barWidth, barHeight);
    	barViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, barWidth, barHeight) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:self.barViewCornerRadiusSize].CGPath;
    }

    UIColor *color = [%c(SparkColourPickerUtils) colourWithString:barColor withFallback:@"#99AAB5"];
    self.barView = [[UIView alloc] initWithFrame:barViewFrame];
    self.barView.backgroundColor = [color colorWithAlphaComponent:barAlpha];
	self.barView.layer.mask = barViewMaskLayer;
    [self.view addSubview:self.barView];

    self.edgePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //self.edgePan.edges = isRightDirection ? UIRectEdgeRight : UIRectEdgeLeft;
	self.edgePan.delegate = self;
	[self.barView addGestureRecognizer:self.edgePan];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(barViewLongPress:)];
	longPress.minimumPressDuration = 0.5;
	[self.barView addGestureRecognizer:longPress];
}

- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture {
	/*
	if ([(SpringBoard *)UIApplication.sharedApplication isLocked])
		return;
	*/

    CGFloat width = self.shortcutView.frame.size.width;
    // TODO: change the shit out of this
    CGFloat percent = MAX(pow(-1, (int)isRightDirection) * [gesture translationInView:gesture.view ].x, 0)/width;
    if (gesture.state == UIGestureRecognizerStateBegan){
    	self.isDraggingShortcutView = YES;
    	panAnimator = [self showingViewPropertyAnimator];
    	[self.view addSubview:self.blurView];
    	[self.view addSubview:self.shortcutView];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
    	if (percent > 1.0)
    		percent = 1.0;

    	panAnimator.fractionComplete = percent;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
    	if (percent >= 0.3)
    		[self showViewWithPropertyAnimator:panAnimator];
    	else {
    		if (percent == 0)
    			self.blurView.effect = nil;

    		[self hideViewWithPropertyAnimator:panAnimator];
    	}
    }
}

- (void)barViewLongPress:(UILongPressGestureRecognizer *)gesture {
	NSLog(@"[RF] barViewLongPress called");
	if (!isBarMovable && !isBarMoving)
		return;

	CGPoint point = [gesture locationInView:self.view];
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
		{
			isBarMoving = YES;
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.backgroundColor = [self.barView.backgroundColor colorWithAlphaComponent:1];
					self.barView.transform = CGAffineTransformScale(self.barView.transform, barWidth / self.barView.frame.size.width * 1.1, barHeight / self.barView.frame.size.height * 1.1);
				}];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
			CGPoint barCenter = self.barView.center;
			barCenter.y += point.y - longPressStartingPoint.y;
			CGRect bounds = UIScreen.mainScreen.bounds;
			if (point.x >= bounds.size.width / 2 && !isRightDirection) { // moving to the right
				barCenter.x = bounds.size.width - (barWidth / 2);
				CAShapeLayer * maskLayer1 = [CAShapeLayer layer];
				maskLayer1.path = [UIBezierPath bezierPathWithRoundedRect:self.barView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:self.barViewCornerRadiusSize].CGPath;
				self.barView.layer.mask = maskLayer1;
				CAShapeLayer * maskLayer2 = [CAShapeLayer layer];
				maskLayer2.path = [UIBezierPath bezierPathWithRoundedRect: self.shortcutView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){10.0, 10.0}].CGPath;
				self.shortcutView.layer.mask = maskLayer2;
				isRightDirection = YES;
				CGPoint shortcutViewCenter = self.shortcutView.center;
				if (!self.isViewVisible) {
					shortcutViewCenter.x = bounds.size.width + (self.shortcutView.frame.size.width / 2);
				}
				else {
					shortcutViewCenter.x = bounds.size.width - (self.shortcutView.frame.size.width / 2);
				}
				self.shortcutView.center = shortcutViewCenter;
			}
			else if (point.x < bounds.size.width / 2 && isRightDirection) { // moving to the left
				barCenter.x = barWidth / 2;
				CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
				maskLayer1.path = [UIBezierPath bezierPathWithRoundedRect:self.barView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:self.barViewCornerRadiusSize].CGPath;
				self.barView.layer.mask = maskLayer1;
				CAShapeLayer * maskLayer2 = [CAShapeLayer layer];
				maskLayer2.path = [UIBezierPath bezierPathWithRoundedRect: self.shortcutView.bounds byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
				self.shortcutView.layer.mask = maskLayer2;
				isRightDirection = NO;
				CGPoint shortcutViewCenter = self.shortcutView.center;
				if (!self.isViewVisible) {
					shortcutViewCenter.x = -1 * self.shortcutView.frame.size.width / 2;
				}
				else {
					shortcutViewCenter.x = self.shortcutView.frame.size.width / 2;
				}
				self.shortcutView.center = shortcutViewCenter;
			}
			self.barView.center = barCenter;
			break;
		}
		case UIGestureRecognizerStateEnded:
		{
			//self.edgePan.edges = isRightDirection ? UIRectEdgeRight : UIRectEdgeLeft;
			isBarMoving = NO;
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.backgroundColor = [self.barView.backgroundColor colorWithAlphaComponent:barAlpha];
					self.barView.transform = CGAffineTransformScale(self.barView.transform, barWidth / self.barView.frame.size.width, barHeight / self.barView.frame.size.height);
				}];

			barViewCenterYPosition = self.barView.center.y;
			[prefs setFloat:self.barView.center.y forKey:@"barViewCenterYPosition"];
			[prefs setBool:isRightDirection forKey:@"isRightDirection"];
			break;
		}
		default:
			break;
	}

	longPressStartingPoint = point;
}

- (UIViewPropertyAnimator *)showingViewPropertyAnimator {
	UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.25
		curve:UIViewAnimationCurveEaseOut
		animations:^{
			CGRect bounds = UIScreen.mainScreen.bounds;
			CGPoint center = self.shortcutView.center;
			if (isRightDirection) {
				center.x = bounds.size.width - (self.shortcutView.frame.size.width / 2);
			}
			else {
				center.x = self.shortcutView.frame.size.width / 2;
			}
			self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			self.shortcutView.center = center;
		}];

	return animator;
}

- (UIViewPropertyAnimator *)hidingViewPropertyAnimator {
	UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.25
		curve:UIViewAnimationCurveEaseIn
		animations:^ {
			CGRect bounds = UIScreen.mainScreen.bounds;
			CGPoint center = self.shortcutView.center;
			if (isRightDirection) {
				center.x = bounds.size.width + (self.shortcutView.frame.size.width / 2);
			}
			else {
				center.x = -1 * self.shortcutView.frame.size.width / 2;
			}
			self.blurView.effect = nil;
			self.shortcutView.center = center;
		}];

	return animator;
}

- (void)showView {
	if (self.isViewVisible && !self.isDraggingShortcutView)
		return;

	self.isViewVisible = YES;
	self.isDraggingShortcutView = NO;
	if (self.blurView.superview == nil)
		[self.view addSubview:self.blurView];
	if (self.shortcutView.superview == nil)
		[self.view addSubview:self.shortcutView];

	UIViewPropertyAnimator *animator = [self showingViewPropertyAnimator];
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self startTimeoutTimer];
	}];
	[animator startAnimation];
}

- (void)hideView {
	if (!self.isViewVisible && !self.isDraggingShortcutView)
		return;

	[self stopTimeoutTimer];

	self.isViewVisible = NO;
	self.isDraggingShortcutView = NO;
	UIViewPropertyAnimator *animator = [self hidingViewPropertyAnimator];
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self.shortcutScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
		if (self.shortcutView.superview != nil)
			[self.shortcutView removeFromSuperview];
		if (self.blurView.superview != nil)
			[self.blurView removeFromSuperview];
	}];
	[animator startAnimation];
}

- (void)showViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator {
	if (self.isViewVisible && !self.isDraggingShortcutView)
		return;

	self.isViewVisible = YES;
	self.isDraggingShortcutView = NO;
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self startTimeoutTimer];
	}];
	[animator startAnimation];
}

- (void)hideViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator {
	if (!self.isViewVisible && !self.isDraggingShortcutView)
		return;

	self.isViewVisible = NO;
	self.isDraggingShortcutView = NO;
	animator.reversed = YES;
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self.shortcutScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
		if (self.shortcutView.superview != nil)
			[self.shortcutView removeFromSuperview];
		if (self.blurView.superview != nil)
			[self.blurView removeFromSuperview];
	}];
	[animator startAnimation];
}

- (void)iconTapped:(id)arg1 {
	[self hideView];
	NSString *bundleID = [((SBIconView *)arg1).icon applicationBundleID];
	//[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
	openApplication(bundleID);
}

- (void)blurViewTapped:(id)arg1 {
	[self hideView];
	/*
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[%c(LSApplicationWorkspace) defaultWorkspace] openSensitiveURL:[NSURL URLWithString:@"prefs:root=Rofi"] withOptions:nil];
	});
	*/
}

- (BOOL)iconViewCanBeginDrags:(id)arg1 {
	return NO;
}

- (void)startTimeoutTimer {
	if (!isTimeoutEnabled)
		return

	[self stopTimeoutTimer];

	timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutDelay target:self selector:@selector(timeoutTimerFired:) userInfo:nil repeats:NO];
}

- (void)stopTimeoutTimer {
	if (timeoutTimer != nil && timeoutTimer.valid)
		[timeoutTimer invalidate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self startTimeoutTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate)
		[self startTimeoutTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self stopTimeoutTimer];
}

- (void)timeoutTimerFired:(NSTimer *)timer {
	[self hideView];
	[self stopTimeoutTimer];
}

- (BOOL)iconViewShouldBeginShortcutsPresentation:(id)arg1 {
	NSLog(@"[RF] iconViewShouldBeginShortcutsPresentation called");
	return YES;
}

- (BOOL)iconView:(id)arg1 shouldActivateApplicationShortcutItem:(id)arg2 atIndex:(unsigned long long)arg3 {
	NSLog(@"[RF] iconView:shouldActivateApplicationShortcutItematIndex: called");
	return YES;
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

/*
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {}

- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1 {}
*/
@end
#import "RFViewController.h"
#import <Cephei/HBPreferences.h>
#import "libcolorpicker.h"
#import <notify.h>

NSLayoutConstraint *barViewCenterXConstraint;
NSLayoutConstraint *barViewCenterYConstraint;
NSLayoutConstraint *barViewWidthConstraint;
NSLayoutConstraint *barViewHeightConstraint;
CGPoint longPressStartingPoint;
UIViewPropertyAnimator *panAnimator;
NSTimer *timeoutTimer;
HBPreferences *prefs;
NSInteger numberOfIcons;
BOOL isRightDirection;
CGFloat barViewCenterYPosition;
//NSArray *apps;
BOOL isBarMovable;
BOOL isBarMoving;
CGFloat barWidth;
CGFloat barHeight;
CGFloat barAlpha;
NSString *barColor;
BOOL isTimeoutEnabled;
NSInteger timeoutDelay;
BOOL isBlurEnabled;
BOOL isCenteredWithBarPosition;
BOOL isBadgesEnabled;

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
		self.barViewCornerRadius = 10;

		prefs = [HBPreferences preferencesForIdentifier:@"com.kef.rofi"];
		numberOfIcons = [prefs integerForKey:@"numberOfIcons" default:4];
		isRightDirection = [prefs boolForKey:@"isRightDirection" default:NO];
		barViewCenterYPosition = [prefs floatForKey:@"barViewCenterYPosition" default:UIScreen.mainScreen.bounds.size.height/2];
		isBadgesEnabled = [prefs boolForKey:@"isBadgesEnabled" default:YES];
		//numberOfIcons = apps.count;

		//[prefs registerInteger:&numberOfIcons default:4 forKey:@"numberOfIcons"];
		[prefs registerBool:&isCenteredWithBarPosition default:YES forKey:@"isCenteredWithBarPosition"];
		[prefs registerBool:&isBlurEnabled default:YES forKey:@"isBlurEnabled"];
		[prefs registerBool:&isBarMovable default:YES forKey:@"isBarMovable"];
		[prefs registerFloat:&barWidth default:10.0 forKey:@"barWidth"];
		[prefs registerFloat:&barHeight default:100.0 forKey:@"barHeight"];
		[prefs registerFloat:&barAlpha default:0.5 forKey:@"barAlpha"];
		[prefs registerObject:&barColor default:@"#99AAB5" forKey:@"barColor"];
		[prefs registerBool:&isTimeoutEnabled default:YES forKey:@"isTimeoutEnabled"];
		[prefs registerInteger:&timeoutDelay default:15 forKey:@"timeoutDelay"];
		[prefs registerPreferenceChangeBlock:^ {
			NSLog(@"[RF] registerPreferenceChangeBlock called");
			self.shortcutView.center = CGPointMake(self.shortcutView.center.x, [self shortcutViewCenterYPositionWithHeight:self.shortcutView.frame.size.height]);
			UIColor *color = LCPParseColorString(barColor, @"#99AAB5");
			//NSLog(@"[RF] user defaults result = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"barColor" inDomain:@"com.kef.rofi"]);
			//NSLog(@"[RF] barColor = %@, color = %@", barColor, color);
			[self.view layoutIfNeeded];
			[UIView animateWithDuration:0.25
				animations:^ {
					barViewHeightConstraint.constant = barHeight;
					barViewWidthConstraint.constant = 2*barWidth;
					[self.view layoutIfNeeded];
					self.barView.backgroundColor = [color colorWithAlphaComponent:barAlpha];
				}
				completion:nil];
		}];

		int notify_token;
		notify_register_dispatch("com.kef.rofi/ReloadNumberOfIcons",
			&notify_token,
			dispatch_get_main_queue(),
			^(int token) {
				numberOfIcons = [prefs integerForKey:@"numberOfIcons" default:4];
				if (!self.shortcutView)
					return;
				
				NSLog(@"[RF] changing prefs/shortcutView frame. numberOfIcons = %ld", numberOfIcons);
				CGRect bounds = UIScreen.mainScreen.bounds;
				CGSize iconSize = [[self getIconView:@"com.apple.Preferences"] _iconImageView].frame.size;
				CGFloat shortcutViewHeight = iconSize.height * numberOfIcons + numberOfIcons * self.shortcutStackViewSpacing;
				CGRect shortcutViewFrame;
				CAShapeLayer *shortcutViewMaskLayer = [CAShapeLayer layer];
				if (isRightDirection) {
					shortcutViewFrame = CGRectMake(bounds.size.width, [self shortcutViewCenterYPositionWithHeight:shortcutViewHeight] - shortcutViewHeight / 2, self.shortcutViewWidth, shortcutViewHeight);
					shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:(CGSize){10.0, 10.0}].CGPath;
				}
				else {
					shortcutViewFrame = CGRectMake(0 - self.shortcutViewWidth, [self shortcutViewCenterYPositionWithHeight:shortcutViewHeight] - shortcutViewHeight / 2, self.shortcutViewWidth, shortcutViewHeight);
					shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){10.0, 10.0}].CGPath;
				}
				self.shortcutView.frame = shortcutViewFrame;
				self.shortcutView.layer.mask = shortcutViewMaskLayer;
			});
	}
	return self;
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (void)reloadIcons {
	self.apps = (NSArray *)[prefs objectForKey:@"selectedApps" default:[[NSArray alloc] init]];
	if (self.shortcutStackView.arrangedSubviews.count) {
		for (UIView *subview in self.shortcutStackView.arrangedSubviews)
			[subview removeFromSuperview];
	}
	for (NSString *app in self.apps) {
    	[self addIconView:app toStackView:self.shortcutStackView];
    }
}

- (UIView *)getIconBadgeViewForIconView:(SBIconView *)iconView {
	if (!isBadgesEnabled)
		return nil;
	
	NSInteger badgeType;
	if (SYSTEM_VERSION_LESS_THAN(@"13"))
		badgeType = [((SBIcon_ios12 *)iconView.icon) accessoryTypeForLocation:1]; // iOS 12-, location 1 = home
	else
		badgeType = [((SBIcon_ios13 *)iconView.icon) accessoryTypeForLocation:@"SBIconLocationRoot"]; // iOS 13, location SBIconLocationRoot = home
	
	BOOL isContinuityBadgeView = SYSTEM_VERSION_LESS_THAN(@"13") ? !![iconView continuityAppSuggestion] : !![iconView continuityInfo]; // null check for continuity badge view
	if (isContinuityBadgeView) {
		SBIconContinuityBadgeView *badgeView = [[%c(SBIconContinuityBadgeView) alloc] init];
		[badgeView configureForIcon:iconView.icon infoProvider:iconView];
		return badgeView;
	}
	else if (badgeType == 1) {
		SBIconBadgeView *badgeView = [[%c(SBIconBadgeView) alloc] init];
		[badgeView configureForIcon:iconView.icon infoProvider:iconView];
		if ([badgeView safeValueForKey:@"_text"])
			return badgeView;
		else
			return nil;
	}
	else
		return nil;
}

- (SBIconView *)getIconView:(NSString *)identifier {
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
	//iconView.delegate = self;
	//iconView.frame = CGRectMake(0, 0, iconView.frame.size.width, iconView.frame.size.height + 10);
	return iconView;
}

- (void)addIconView:(NSString *)identifier toStackView:(UIStackView *)stackView {
	SBIconView *iconView = [self getIconView:identifier];
	if (!iconView)
		return;

	// get center before adding to stack view, to avoid weird badge placement
	CGPoint badgeCenter;
	CGRect badgeFrame;
	if (SYSTEM_VERSION_LESS_THAN(@"12"))
		badgeFrame = [iconView _frameForAccessoryView];
	else
		badgeCenter = [iconView _centerForAccessoryView];
	
	UIView *imageView = [iconView _iconImageView];
	for (UIView *subview in imageView.subviews) { // removing notification badges (because iOS 13 adds them by default)
		[subview removeFromSuperview];
	}
	imageView.insetsLayoutMarginsFromSafeArea = NO;
	CGFloat iconWidth = imageView.frame.size.width;
	CGFloat iconHeight = imageView.frame.size.height;
	[stackView addArrangedSubview:imageView];
    [imageView.widthAnchor constraintEqualToConstant:iconWidth].active = true;
    [imageView.heightAnchor constraintEqualToConstant:iconHeight].active = true;
	// adding notification badge
	UIView *badge = [self getIconBadgeViewForIconView:iconView];
	if (badge) {
		if (SYSTEM_VERSION_LESS_THAN(@"12"))
			badge.frame = badgeFrame;
		else
			badge.center = badgeCenter;
		
		[imageView addSubview:badge];
	}

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapped:)];
	[imageView addGestureRecognizer:tapRecognizer];
	imageView.userInteractionEnabled = YES;
}

- (CGFloat)shortcutViewCenterYPositionWithHeight:(CGFloat)shortcutViewHeight {
	CGRect bounds = UIScreen.mainScreen.bounds;
	if (!isCenteredWithBarPosition)
		return bounds.size.height / 2;
	else if (barViewCenterYPosition + (shortcutViewHeight / 2) > bounds.size.height)
		return bounds.size.height - shortcutViewHeight / 2;
	else if (barViewCenterYPosition - (shortcutViewHeight / 2) < 0)
		return shortcutViewHeight / 2;
	else
		return barViewCenterYPosition;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	CGSize iconSize = [[self getIconView:@"com.apple.Preferences"] _iconImageView].frame.size;

	self.shortcutViewWidth = iconSize.width + 25;
	self.shortcutStackViewSpacing = 24;
	CGFloat shortcutStackViewMarginTop = self.shortcutStackViewSpacing / 2;
	CGFloat shortcutStackViewMarginBottom = shortcutStackViewMarginTop;
	CGFloat shortcutViewHeight = iconSize.height * numberOfIcons + numberOfIcons * self.shortcutStackViewSpacing;

	CGRect bounds = [[UIScreen mainScreen] bounds];

	CGRect shortcutViewFrame;
	CAShapeLayer *shortcutViewMaskLayer = [CAShapeLayer layer];
    if (isRightDirection) {
    	shortcutViewFrame = CGRectMake(bounds.size.width, [self shortcutViewCenterYPositionWithHeight:shortcutViewHeight] - shortcutViewHeight / 2, self.shortcutViewWidth, shortcutViewHeight);
    	shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:(CGSize){10.0, 10.0}].CGPath;
    }
    else {
    	shortcutViewFrame = CGRectMake(0 - self.shortcutViewWidth, [self shortcutViewCenterYPositionWithHeight:shortcutViewHeight] - shortcutViewHeight / 2, self.shortcutViewWidth, shortcutViewHeight);
    	shortcutViewMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.shortcutViewWidth, shortcutViewHeight) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){10.0, 10.0}].CGPath;
    }
	self.shortcutView = [[RFView alloc] initWithFrame:shortcutViewFrame];
	self.shortcutView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
	self.shortcutView.layer.mask = shortcutViewMaskLayer;
	self.shortcutView.insetsLayoutMarginsFromSafeArea = NO;
	self.shortcutPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleShortcutPan:)];
	self.shortcutPan.delegate = self;
	[self.shortcutView addGestureRecognizer:self.shortcutPan];

	self.shortcutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.shortcutView.frame.size.width, self.shortcutView.frame.size.height)];
	self.shortcutScrollView.translatesAutoresizingMaskIntoConstraints = false;
	self.shortcutScrollView.showsVerticalScrollIndicator = NO;
	self.shortcutScrollView.pagingEnabled = YES;
	self.shortcutScrollView.delegate = self;
	//self.shortcutScrollView.insetsLayoutMarginsFromSafeArea = NO;

	self.blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
	self.blurView.frame = self.view.bounds;
	self.blurView.backgroundColor = UIColor.clearColor;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewTapped:)];
	[self.blurView addGestureRecognizer:tapRecognizer];

	self.shortcutStackView = [[UIStackView alloc] init];
	self.shortcutStackView.axis = UILayoutConstraintAxisVertical;
	self.shortcutStackView.distribution = UIStackViewDistributionEqualSpacing;
	self.shortcutStackView.alignment = UIStackViewAlignmentLeading;
	self.shortcutStackView.spacing = self.shortcutStackViewSpacing;
	self.shortcutStackView.layoutMarginsRelativeArrangement = YES;
	self.shortcutStackView.insetsLayoutMarginsFromSafeArea = NO;
	self.shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(shortcutStackViewMarginTop, 0, shortcutStackViewMarginBottom, 0);

	self.shortcutStackView.translatesAutoresizingMaskIntoConstraints = false;
	[self.shortcutScrollView addSubview:self.shortcutStackView];
	[self.shortcutView addSubview:self.shortcutScrollView];

	[self.shortcutScrollView.leadingAnchor constraintEqualToAnchor:self.shortcutView.leadingAnchor].active = true;
    [self.shortcutScrollView.trailingAnchor constraintEqualToAnchor:self.shortcutView.trailingAnchor].active = true;
    [self.shortcutScrollView.topAnchor constraintEqualToAnchor:self.shortcutView.topAnchor].active = true;
    [self.shortcutScrollView.bottomAnchor constraintEqualToAnchor:self.shortcutView.bottomAnchor].active = true;

    [self.shortcutStackView.centerXAnchor constraintEqualToAnchor:self.shortcutScrollView.centerXAnchor].active = true;
	//[self.shortcutStackView.centerYAnchor constraintEqualToAnchor:self.shortcutScrollView.centerYAnchor].active = true;
    [self.shortcutStackView.topAnchor constraintEqualToAnchor:self.shortcutScrollView.topAnchor].active = true;
    [self.shortcutStackView.bottomAnchor constraintEqualToAnchor:self.shortcutScrollView.bottomAnchor].active = true;

    [self reloadIcons];

    UIColor *color = LCPParseColorString(barColor, @"#99AAB5");
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.barView.backgroundColor = [color colorWithAlphaComponent:barAlpha];
	self.barView.translatesAutoresizingMaskIntoConstraints = false;
	self.barView.insetsLayoutMarginsFromSafeArea = NO;
    [self.view addSubview:self.barView];

    NSLog(@"[RF] barViewCenterYPosition = %f", barViewCenterYPosition);
    if (isRightDirection) {
    	barViewCenterXConstraint = [self.barView.centerXAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:bounds.size.width];
    }
    else {
    	barViewCenterXConstraint = [self.barView.centerXAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0];
    }
    //self.barView.layer.mask = barViewMaskLayer;
    self.barView.layer.cornerRadius = self.barViewCornerRadius;
    self.barView.layer.masksToBounds = true;
    barViewCenterYConstraint = [self.barView.centerYAnchor constraintEqualToAnchor:self.view.topAnchor constant:barViewCenterYPosition];
    barViewWidthConstraint = [self.barView.widthAnchor constraintEqualToConstant:2*barWidth];
    barViewHeightConstraint = [self.barView.heightAnchor constraintEqualToConstant:barHeight];

    barViewCenterXConstraint.active = true;
    barViewCenterYConstraint.active = true;
    barViewWidthConstraint.active = true;
    barViewHeightConstraint.active = true;

    self.barEdgePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleBarEdgePan:)];
	self.barEdgePan.delegate = self;
	[self.barView addGestureRecognizer:self.barEdgePan];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(barViewLongPress:)];
	longPress.minimumPressDuration = 0.5;
	[self.barView addGestureRecognizer:longPress];
}

- (void)handleShortcutPan:(UIPanGestureRecognizer *)gesture {
	CGFloat width = self.shortcutView.frame.size.width;
	CGFloat percent = MAX(pow(-1, (int)!isRightDirection) * [gesture translationInView:gesture.view].x, 0)/width;
	//percent = 1 - percent;
	NSLog(@"[RF] handleShortcutPan called. percent = %f", percent);
	if (gesture.state == UIGestureRecognizerStateBegan){
    	self.isDraggingShortcutView = YES;
    	panAnimator = [self hidingViewPropertyAnimator];
    	//[self.view addSubview:self.blurView];
    	//[self.view addSubview:self.shortcutView];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
    	if (percent < 0.0)
    		percent = 0.0;

    	panAnimator.fractionComplete = percent;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
    	if (percent >= 0.3)
    		[self hideViewWithPropertyAnimator:panAnimator isHiding:YES];
    	else {
			/*
    		if (percent == 1) {
    			self.blurView.effect = nil;
				self.blurView.backgroundColor = UIColor.clearColor;
			}
			*/

    		[self showViewWithPropertyAnimator:panAnimator isHiding:YES];
    	}
    }
}

- (void)handleBarEdgePan:(UIPanGestureRecognizer *)gesture {
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
    		[self showViewWithPropertyAnimator:panAnimator isHiding:NO];
    	else {
    		if (percent == 0) {
    			self.blurView.effect = nil;
				self.blurView.backgroundColor = UIColor.clearColor;
			}

    		[self hideViewWithPropertyAnimator:panAnimator isHiding:NO];
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
					barViewHeightConstraint.constant = barHeight + 10;
					[self.view layoutIfNeeded];
				}];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
			CGPoint barCenter = self.barView.center;
			barCenter.y += point.y - longPressStartingPoint.y;
			CGRect bounds = UIScreen.mainScreen.bounds;
			if (point.x >= bounds.size.width / 2 && !isRightDirection) { // moving to the right
				barCenter.x = bounds.size.width;
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
				barCenter.x = 0;
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
			barViewCenterXConstraint.constant = barCenter.x;
			barViewCenterYConstraint.constant = barCenter.y;

			break;
		}
		case UIGestureRecognizerStateEnded:
		{
			isBarMoving = NO;
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.backgroundColor = [self.barView.backgroundColor colorWithAlphaComponent:barAlpha];
					barViewHeightConstraint.constant = barHeight - 10;
					[self.view layoutIfNeeded];
				}];

			barViewCenterYPosition = self.barView.center.y;
			[prefs setFloat:self.barView.center.y forKey:@"barViewCenterYPosition"];
			[prefs setBool:isRightDirection forKey:@"isRightDirection"];
			CGPoint shortcutViewCenter = self.shortcutView.center;
			shortcutViewCenter.y = [self shortcutViewCenterYPositionWithHeight:self.shortcutView.frame.size.height];
			self.shortcutView.center = shortcutViewCenter;
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
			if (isBlurEnabled)
				self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			else
				self.blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
			
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
			self.blurView.backgroundColor = UIColor.clearColor;
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

- (void)showViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator isHiding:(BOOL)isHiding {
	if (self.isViewVisible && !self.isDraggingShortcutView)
		return;

	self.isViewVisible = YES;
	self.isDraggingShortcutView = NO;
	animator.reversed = isHiding;
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self startTimeoutTimer];
	}];
	[animator startAnimation];
}

- (void)hideViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator isHiding:(BOOL)isHiding {
	if (!self.isViewVisible && !self.isDraggingShortcutView)
		return;

	self.isViewVisible = NO;
	self.isDraggingShortcutView = NO;
	animator.reversed = !isHiding;
	[animator addCompletion:^ (UIViewAnimatingPosition finalPosition) {
		[self.shortcutScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
		if (self.shortcutView.superview != nil)
			[self.shortcutView removeFromSuperview];
		if (self.blurView.superview != nil)
			[self.blurView removeFromSuperview];
	}];
	[animator startAnimation];
}

- (void)iconTapped:(UITapGestureRecognizer *)arg1 {
	[self hideView];
	NSString *bundleID = [((SBIconImageView *)arg1.view).icon applicationBundleID];
	openApplication(bundleID);
}

- (void)blurViewTapped:(id)arg1 {
	if (panAnimator && panAnimator.state != UIViewAnimatingStateStopped)
		return;
	
	[self hideView];
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

- (BOOL)_canShowWhileLocked {
	return YES;
}
@end
#import "SCViewController.h"
#import "SCView.h"
#import "Tweak.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

CGPoint longPressStartingPoint;

@implementation SCViewController

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
	}
	else {
		/*
		NSLog(@"[SC] SBIcon = %@", icon);
		iconView = [[((SBIconController *)[%c(SBIconController) sharedInstance]) iconManager] iconViewForIcon:icon location:@"SBIconLocationRoot"];
		NSLog(@"[SC] iconView = %@", iconView);
		*/
		iconView = [[%c(SBIconView) alloc] initWithConfigurationOptions:0];
	}
	iconView.icon = icon;
	iconView.delegate = self;
	NSLog(@"iconView = %@", iconView);
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

	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGFloat ratio = 0.7;
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
	self.shortcutStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(10, 0, 20, 0);

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

    /*
    [self addIconViewToStackView:@"com.facebook.Facebook"];
    [self addIconViewToStackView:@"com.hammerandchisel.discord"];
    [self addIconViewToStackView:@"net.whatsapp.WhatsApp"];
    [self addIconViewToStackView:@"com.facebook.Messenger"];
    [self addIconViewToStackView:@"com.burbn.instagram"];
    */

    [self addIconViewToStackView:@"com.hammerandchisel.discord"];
    [self addIconViewToStackView:@"com.atebits.Tweetie2"];
    [self addIconViewToStackView:@"com.apple.mobilesafari"];
    [self addIconViewToStackView:@"net.whatsapp.WhatsApp"];
    [self addIconViewToStackView:@"com.burbn.instagram"];
    [self addIconViewToStackView:@"com.toyopagroup.picaboo"];

    self.barView = [[UIView alloc] initWithFrame:CGRectMake(bounds.size.width - 10, 100, 10, 100)];
    self.barView.backgroundColor = [UIColor colorWithRed:0.6 green:0.67 blue:0.71 alpha:0.5];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.barView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){10.0, 10.0}].CGPath;
	self.barView.layer.mask = maskLayer;
    [self.view addSubview:self.barView];

    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [pan setEdges:UIRectEdgeRight];
	[pan setDelegate:self];
	[self.barView addGestureRecognizer:pan];

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	longPress.minimumPressDuration = 0.5;
	[self.barView addGestureRecognizer:longPress];
}

- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture {
	NSLog(@"handlePan called");
	if ([(SpringBoard *)UIApplication.sharedApplication isLocked])
		return;

    CGFloat width = self.shortcutView.frame.size.width;
    CGFloat percent = MAX(-[gesture translationInView:gesture.view ].x, 0)/width;
    if (gesture.state == UIGestureRecognizerStateEnded) {
    	if (percent >= 0.25)
    		[self showView];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
	CGPoint point = [gesture locationInView:self.view];
	NSLog(@"point = %@", NSStringFromCGPoint(point));
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
		{
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.backgroundColor = [self.barView.backgroundColor colorWithAlphaComponent:1];
				}];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
			CGPoint center = self.barView.center;
			center.y += point.y - longPressStartingPoint.y;
			self.barView.center = center;
			break;
		}
		case UIGestureRecognizerStateEnded:
		{
			[UIView animateWithDuration:0.25
				animations:^ {
					self.barView.backgroundColor = [self.barView.backgroundColor colorWithAlphaComponent:0.5];
				}];
			break;
		}
		default:
			break;
	}

	longPressStartingPoint = point;
}

- (void)showView {
	if (self.isViewVisible)
		return;

	self.isViewVisible = YES;
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
	if (!self.isViewVisible)
		return;

	self.isViewVisible = NO;
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
/*
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {}

- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1 {}
*/
@end
#import "Tweak.h"
#import "RFView.h"
#import "RFViewController.h"
#import <Cephei/HBPreferences.h>
#import <notify.h>

@interface RFWindow : SBSecureWindow
@end

static RFWindow *window;
static RFViewController *viewController;
static UIScreenEdgePanGestureRecognizer *pan;
static BOOL isEnabled;
static BOOL hideWhenTakingScreenshots;

%subclass RFWindow : SBSecureWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *viewAtPoint = [self.rootViewController.view hitTest:point withEvent:event];
	if (!viewAtPoint || (viewAtPoint == self.rootViewController.view)) return NO;
	else return YES;
}
%end

%hook SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	UIPress *press = arg1.allPresses.anyObject;
	/*
	if (press.type == 102 && press.force == 1) {
		NSLog(@"Posting notification: showview");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test/showview" object:nil];
	}
	else if (press.type == 103 && press.force == 1) {
		NSLog(@"Posting notification: hideview");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.kef.test/hideview" object:nil];
	}
	*/
	if (press.type == 101 && press.force == 1 && viewController.isViewVisible) {
		[viewController hideView];
		return NO;
	}
	return %orig;
}

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	if (!isEnabled)
		return;

	viewController = [RFViewController new];
	//window = [[%c(RFWindow) alloc] initWithFrame:UIScreen.mainScreen.bounds];
	window = [[%c(RFWindow) alloc] initWithScreen:UIScreen.mainScreen debugName:@"Rofi" rootViewController:viewController];
	window.screen = UIScreen.mainScreen;
	//window.rootViewController = viewController;
	window.userInteractionEnabled = YES;
	window.opaque = NO;
	window.hidden = NO;
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = 1074; // CC Window - 1 //UIWindowLevelAlert + 1;
	/*
	pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:window.rootViewController action:@selector(handlePan:)];
	[pan setEdges:UIRectEdgeRight];
	[pan setDelegate:(RFViewController *)window.rootViewController];
	[window.rootViewController.view addGestureRecognizer:pan];
	SBSystemGestureManager *gestureManager = [%c(SBSystemGestureManager) mainDisplayManager];
	FBSDisplayIdentity *dispIdentity = MSHookIvar<FBSDisplayIdentity *>(gestureManager, "_displayIdentity");
	[[%c(FBSystemGestureManager) sharedInstance] addGestureRecognizer:pan toDisplayWithIdentity:dispIdentity];
	*/
}

- (void)takeScreenshot {
	NSLog(@"[RF] takeScreenshot called!");
	if (hideWhenTakingScreenshots)
		viewController.barView.alpha = 0;
	
	%orig;
}

- (void)screenCapturer:(id)arg1 didCaptureScreenshotsOfScreens:(id)arg2 {
	NSLog(@"[RF] screenCapturer:didCaptureScreenshotsOfScreens: called!");
	if (hideWhenTakingScreenshots)
		viewController.barView.alpha = 1;
	
	%orig;
}

%end

%hook SBIconView
- (void)_updateAccessoryViewWithAnimation:(BOOL)arg1 {
	%orig;
	UIView *badge = [self valueForKey:@"_accessoryView"];
	//UIView *badge = MSHookIvar<UIView *>(self, "_accessoryView");
	if (!viewController || !viewController.shortcutStackView)
		return;
	
	for (SBIconImageView *subview in viewController.shortcutStackView.arrangedSubviews) {
		if ([[subview.icon applicationBundleID] isEqualToString:[self.icon applicationBundleID]]) {
			for (UIView *accessory in subview.subviews) {
				[accessory removeFromSuperview];
			}
			if (!badge || ([badge isKindOfClass:%c(SBIconView)] && ![badge valueForKey:@"_text"]))
				return;
			
			NSLog(@"[RF] badge _text = %@", [badge valueForKey:@"_text"]);
			SBIconBadgeView *temp = [[%c(SBIconBadgeView) alloc] init];
			[temp configureForIcon:self.icon infoProvider:self];
			if (SYSTEM_VERSION_LESS_THAN(@"12"))
				temp.frame = [self _frameForAccessoryView];
			else
				temp.center = [self _centerForAccessoryView];
			[subview addSubview:temp];
			return;
		}
	}
}


- (void)_destroyAccessoryView:(id)arg1 {
	NSLog(@"[RF] _destroyAccessoryView called");
	%orig;
	if (!viewController || !viewController.shortcutStackView)
		return;
	
	for (SBIconImageView *subview in viewController.shortcutStackView.arrangedSubviews) {
		if ([[subview.icon applicationBundleID] isEqualToString:[self.icon applicationBundleID]]) {
			for (UIView *accessory in subview.subviews) {
				[accessory removeFromSuperview];
			}
		}
	}
}

%end

%ctor {
	HBPreferences *prefs = [HBPreferences preferencesForIdentifier:@"com.kef.rofi"];
	isEnabled = [prefs boolForKey:@"isEnabled" default:YES];
	[prefs registerBool:&hideWhenTakingScreenshots default:NO forKey:@"hideWhenTakingScreenshots"];
	NSLog(@"[RF] isEnabled = %@", isEnabled ? @"YES" : @"NO");
	// com.apple.iokit.hid.displayStatus state: 0 = off, 1 = on
	// com.apple.springboard.hasBlankedScreen state: 0 = on, 1 = off
	int notify_token_1;
	notify_register_dispatch("com.apple.springboard.hasBlankedScreen",
		&notify_token_1,
		dispatch_get_main_queue(),
		^(int token) {
			uint64_t state = UINT64_MAX;
            notify_get_state(token, &state);
            if (state == 1) {
            	[viewController hideView];
            }
        });
	
	int notify_token_2;
	notify_register_dispatch("com.spark.snowboard.refreshComplete",
		&notify_token_2,
		dispatch_get_main_queue(),
		^(int token) {
			NSLog(@"[RF] Snowboard refresh completed!");
			if (!viewController || !viewController.shortcutStackView)
				return;
			
			[viewController reloadIcons];
        });
	
	int notify_token_3;
	notify_register_dispatch("com.kef.rofi/ReloadApps",
		&notify_token_3,
		dispatch_get_main_queue(),
		^(int token) {
			NSLog(@"[RF] Reloading apps...");
			if (!viewController || !viewController.shortcutStackView)
				return;
			
			[viewController reloadIcons];
        });
}
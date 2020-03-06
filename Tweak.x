#import "Tweak.h"
#import "RFView.h"
#import "RFViewController.h"

@interface RFWindow : UIWindow
@end

static RFWindow *window;
static RFViewController *viewController;
static UIScreenEdgePanGestureRecognizer *pan;

%subclass RFWindow : UIWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *viewAtPoint = [self.rootViewController.view hitTest:point withEvent:event];
	BOOL ret;
	if (!viewAtPoint || (viewAtPoint == self.rootViewController.view)) ret = NO;
	else ret = YES;
	return ret;
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
	viewController = [RFViewController new];
	window = [[%c(RFWindow) alloc] initWithFrame:UIScreen.mainScreen.bounds];
	window.screen = UIScreen.mainScreen;
	window.rootViewController = viewController;
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

%end
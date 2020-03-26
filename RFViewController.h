#import "RFView.h"
#import "SBIconViewDelegate.h"
#import "Tweak.h"

@protocol SBUIActiveOrientationObserver <NSObject>
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3;
- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1;
@end

@interface RFViewController : UIViewController <SBIconViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>//, SBUIActiveOrientationObserver>
@property (nonatomic, assign) BOOL isViewVisible;
@property (nonatomic, assign) BOOL isDraggingShortcutView;
@property (nonatomic, assign) CGSize barViewCornerRadiusSize;
@property (nonatomic, retain) RFView *shortcutView;
@property (nonatomic, retain) UIStackView *shortcutStackView;
@property (nonatomic, retain) UIScrollView *shortcutScrollView;
@property (nonatomic, retain) UIVisualEffectView *blurView;
@property (nonatomic, retain) UIView *barView;
@property (nonatomic, retain) UIPanGestureRecognizer *edgePan;
- (SBIconView *)getIconView:(NSString *)identifier;
- (void)addIconViewToStackView:(NSString *)identifier;
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture;
- (UIViewPropertyAnimator *)showingViewPropertyAnimator;
- (UIViewPropertyAnimator *)hidingViewPropertyAnimator;
- (void)showView;
- (void)hideView;
- (void)showViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator;
- (void)hideViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator;
- (void)blurViewTapped:(id)arg1;
- (void)startTimeoutTimer;
- (void)timeoutTimerFired:(NSTimer *)timer;
@end
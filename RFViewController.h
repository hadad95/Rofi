#import "RFView.h"
#import "SBIconViewDelegate.h"
#import "Tweak.h"

@interface RFViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isViewVisible;
@property (nonatomic, assign) BOOL isDraggingShortcutView;
@property (nonatomic, assign) CGFloat barViewCornerRadius;
@property (nonatomic, retain) RFView *shortcutView;
@property (nonatomic, retain) UIStackView *shortcutStackView;
@property (nonatomic, retain) UIScrollView *shortcutScrollView;
@property (nonatomic, retain) UIVisualEffectView *blurView;
@property (nonatomic, retain) UIView *barView;
@property (nonatomic, retain) UIPanGestureRecognizer *edgePan;
- (SBIconView *)getIconView:(NSString *)identifier;
- (void)addIconView:(NSString *)identifier toStackView:(UIStackView *)stackView;
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture;
- (UIViewPropertyAnimator *)showingViewPropertyAnimator;
- (UIViewPropertyAnimator *)hidingViewPropertyAnimator;
- (void)showView;
- (void)hideView;
- (void)showViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator;
- (void)hideViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator;
- (void)blurViewTapped:(id)arg1;
- (void)startTimeoutTimer;
- (void)stopTimeoutTimer;
- (void)timeoutTimerFired:(NSTimer *)timer;
@end
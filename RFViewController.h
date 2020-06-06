#import "RFView.h"
#import "SBIconViewDelegate.h"
#import "Tweak.h"

@interface RFViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isViewVisible;
@property (nonatomic, assign) BOOL isDraggingShortcutView;
@property (nonatomic, assign) CGFloat barViewCornerRadius;
@property (nonatomic, assign) CGFloat shortcutStackViewSpacing;
@property (nonatomic, assign) CGFloat shortcutViewWidth;
@property (nonatomic, retain) RFView *shortcutView;
@property (nonatomic, retain) UIStackView *shortcutStackView;
@property (nonatomic, retain) UIScrollView *shortcutScrollView;
@property (nonatomic, retain) UIVisualEffectView *blurView;
@property (nonatomic, retain) UIView *barView;
@property (nonatomic, retain) UIPanGestureRecognizer *barEdgePan;
@property (nonatomic, retain) UIPanGestureRecognizer *shortcutPan;
@property (nonatomic, retain) NSArray *apps;
- (SBIconView *)getIconView:(NSString *)identifier;
- (void)addIconView:(NSString *)identifier toStackView:(UIStackView *)stackView;
- (void)reloadIcons;
- (void)handleShortcutPan:(UIPanGestureRecognizer *)gesture;
- (void)handleBarEdgePan:(UIPanGestureRecognizer *)gesture;
- (UIViewPropertyAnimator *)showingViewPropertyAnimator;
- (UIViewPropertyAnimator *)hidingViewPropertyAnimator;
- (void)showView;
- (void)hideView;
- (void)showViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator isHiding:(BOOL)isHiding;
- (void)hideViewWithPropertyAnimator:(UIViewPropertyAnimator *)animator isHiding:(BOOL)isHiding;
- (void)blurViewTapped:(id)arg1;
- (void)startTimeoutTimer;
- (void)stopTimeoutTimer;
- (void)timeoutTimerFired:(NSTimer *)timer;
@end
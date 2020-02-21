#import "SCView.h"
#import "SBIconViewDelegate.h"
#import "Tweak.h"

@protocol SBUIActiveOrientationObserver <NSObject>
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3;
- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1;
@end

@interface SCViewController : UIViewController <SBIconViewDelegate, UIGestureRecognizerDelegate, SBUIActiveOrientationObserver>
@property (nonatomic, assign) BOOL viewIsVisible;
@property (nonatomic, retain) SCView *shortcutView;
@property (nonatomic, retain) UIStackView *shortcutStackView;
@property (nonatomic, retain) UIScrollView *shortcutScrollView;
@property (nonatomic, retain) UIVisualEffectView *blurView;
- (SBIconView *)getIconView:(NSString *)identifier;
- (void)addIconViewToStackView:(NSString *)identifier;
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture;
- (void)showView;
- (void)hideView;
- (void)iconTapped:(id)arg1;
-(void)blurViewTapped:(id)arg1;
@end
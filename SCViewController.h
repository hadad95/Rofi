#import "SCView.h"
#import "SBIconViewDelegate.h"
#import "Tweak.h"

@interface SCViewController : UIViewController <SBIconViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL viewIsVisible;
@property (nonatomic, retain) SCView *shortcutView;
@property (nonatomic, retain) UIStackView *shortcutStackView;
@property (nonatomic, retain) UIScrollView *shortcutScrollView;
@property (nonatomic, retain) UIVisualEffectView *blurView;
- (SBIconView *)getIconView:(NSString *)identifier;
- (void)addIconViewToStackView:(NSString *)identifier;
- (void)handlePan;
- (void)showView;
- (void)hideView;
- (void)iconTapped:(id)arg1;
-(void)blurViewTapped:(id)arg1;
@end
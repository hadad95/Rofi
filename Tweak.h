#import "SBIconViewDelegate.h"

@interface FBSystemGestureManager : NSObject <UIGestureRecognizerDelegate>
+ (id)sharedInstance;
- (void)addGestureRecognizer:(id)arg1 toDisplayWithIdentity:(id)arg2;
@end

@interface SBSystemGestureManager : NSObject
+ (id)mainDisplayManager;
@end

@interface FBSDisplayIdentity : NSObject
@end

@interface SBHomeScreenViewController : UIViewController <SBIconViewDelegate>
@property (nonatomic, assign) BOOL viewIsVisible;
- (void)showView;
- (void)hideView;
- (void)iconTapped:(id)arg1;
@end

@interface SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1;
- (void)applicationDidFinishLaunching:(id)application;
- (BOOL)isLocked;
@end

@interface SBIcon
- (id)applicationBundleID;
@end

@interface SBIconModel
- (id)expectedIconForDisplayIdentifier:(id)arg1;
@end

@interface SBIconViewMap
- (id)mappedIconViewForIcon:(id)arg1;
- (id)extraIconViewForIcon:(id)arg1;
@end

@interface SBIconController : UIViewController
+ (SBIconController *)sharedInstance;
@property(retain, nonatomic) SBIconModel *model;
@property(readonly, nonatomic) SBIconViewMap *homescreenIconViewMap;
@end

@interface SBIconView : UIView
- (id)initWithContentType:(NSUInteger)arg1;
@property(retain, nonatomic) SBIcon *icon;
@property(nonatomic) __weak id delegate;
@end

@interface SBApplication
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

@interface SBApplicationIcon : SBIcon
- (id)initWithApplication:(id)arg1;
@end

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end
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

// ios 13 stuff
@interface SBHIconManager : NSObject
- (id)firstIconViewForIcon:(id)arg1;
- (void)configureIconView:(id)arg1 forIcon:(id)arg2;
- (id)iconViewForIcon:(id)arg1 location:(id)arg2;
- (id)iconViewMap;
@end

@interface SBIconController : UIViewController
@property(retain, nonatomic) SBIconModel *model;
@property(readonly, nonatomic) SBIconViewMap *homescreenIconViewMap;
+ (SBIconController *)sharedInstance;
- (SBHIconManager *)iconManager; // ios 13
@end

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon *icon;
@property(nonatomic) __weak id delegate;
- (id)initWithContentType:(NSUInteger)arg1; // ios 12
- (id)initWithConfigurationOptions:(NSUInteger)arg1; // ios 13
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
#import "SBIconViewDelegate.h"

@interface SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1;
- (void)applicationDidFinishLaunching:(id)application;
- (BOOL)isLocked;
- (void)takeScreenshot;
- (void)screenCapturer:(id)arg1 didCaptureScreenshotsOfScreens:(id)arg2;
@end

@interface SBSecureWindow : UIWindow
-(instancetype)initWithScreen:(UIScreen*)screen debugName:(NSString*)debugName rootViewController:(UIViewController*)viewController;
@end

@interface FBSOpenApplicationOptions : NSObject
+ (id)optionsWithDictionary:(id)arg1;
@end

@interface FBProcess : NSObject
@end

@interface FBApplicationProcess : FBProcess
@end

@interface FBProcessManager : NSObject
+ (id)sharedInstance;
- (FBApplicationProcess *)systemApplicationProcess;
@end

@interface FBSystemServiceOpenApplicationRequest : NSObject
@property (assign,getter=isTrusted,nonatomic) BOOL trusted;
@property (nonatomic,copy) NSString *bundleIdentifier;
@property (nonatomic,copy) FBSOpenApplicationOptions *options;
@property (nonatomic,retain) FBProcess *clientProcess;
+ (id)request;
@end

@interface FBSystemService : NSObject
+ (id)sharedInstance;
@end

@interface SBMainWorkspace : NSObject
+ (id)sharedInstance;
- (void)systemService:(id)arg1 handleOpenApplicationRequest:(id)arg2 withCompletion:(id)arg3 ;
@end

@interface UIViewController (Private)
- (BOOL)_canShowWhileLocked;
@end

@interface SBIcon
- (id)applicationBundleID;
- (void)setBadge:(UIView *)arg1;
@end

@interface SBIconModel
- (id)expectedIconForDisplayIdentifier:(id)arg1;
@end

@interface SBIconController : UIViewController
@property(retain, nonatomic) SBIconModel *model;
+ (SBIconController *)sharedInstance;
@end

@interface SBIconImageView : UIImageView
@property (nonatomic,readonly) SBIcon * icon;
@end

@interface SBIconBadgeView : UIView
- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2;
@end

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon *icon;
@property (nonatomic,readonly) UIView *labelView;
@property(nonatomic) __weak id delegate;
+ (CGSize)defaultIconImageSize;
- (id)initWithContentType:(NSUInteger)arg1; // ios 12
- (id)initWithConfigurationOptions:(NSUInteger)arg1; // ios 13
- (SBIconImageView *)_iconImageView;
- (void)_updateAccessoryViewWithAnimation:(BOOL)arg1;
- (CGPoint)_centerForAccessoryView;
- (void)_destroyAccessoryView:(id)arg1;
@end

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (bool)openSensitiveURL:(id)arg1 withOptions:(id)arg2;
@end
/*
@interface NSUserDefaults (private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
*/
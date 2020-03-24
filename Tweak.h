#import "SBIconViewDelegate.h"

@interface SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1;
- (void)applicationDidFinishLaunching:(id)application;
- (BOOL)isLocked;
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

@interface UIViewController (private)
- (BOOL)_canShowWhileLocked;
@end

@interface SBIcon
- (id)applicationBundleID;
@end

@interface SBIconModel
- (id)expectedIconForDisplayIdentifier:(id)arg1;
@end

@interface SBIconController : UIViewController
@property(retain, nonatomic) SBIconModel *model;
+ (SBIconController *)sharedInstance;
@end

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon *icon;
@property(nonatomic) __weak id delegate;
- (id)initWithContentType:(NSUInteger)arg1; // ios 12
- (id)initWithConfigurationOptions:(NSUInteger)arg1; // ios 13
@end

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (bool)openSensitiveURL:(id)arg1 withOptions:(id)arg2;
@end

@interface NSUserDefaults (private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
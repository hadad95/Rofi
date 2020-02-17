@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, assign) BOOL viewIsVisible;
@end

@interface SpringBoard
- (BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1;
@end

@interface SBIcon
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
#import "SCViewIconViewController.h"
#import "Tweak.h"

@implementation SCViewIconViewController

+ (SCViewIconViewController *)sharedInstance
{
    static SCViewIconViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SCViewIconViewController alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)iconTapped:(id)arg1 {
	NSString *bundleID = [((SBIconView *)arg1).icon applicationBundleID];
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}
@end
#import "SBIconViewDelegate.h"

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface SCViewIconViewController : NSObject <SBIconViewDelegate>
+ (SCViewIconViewController *)sharedInstance;
- (void)iconTapped:(id)arg1;
@end
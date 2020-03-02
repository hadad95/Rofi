@protocol SBIconViewDelegate <NSObject>

@optional
- (void)iconTapped:(id)arg1;
- (BOOL)iconViewCanBeginDrags:(id)arg1;
- (BOOL)iconViewShouldBeginShortcutsPresentation:(id)arg1; // ios 13
- (BOOL)iconView:(id)arg1 shouldActivateApplicationShortcutItem:(id)arg2 atIndex:(unsigned long long)arg3; // ios 13
@end
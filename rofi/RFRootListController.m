#include "RFRootListController.h"
#include <objc/runtime.h>

@interface PreferencesAppController : UIApplication
- (void)generateURL;
@end

@implementation RFRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)respring {
}

@end

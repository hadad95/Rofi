#import "RFSpecialThanksListController.h"

@implementation RFSpecialThanksListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"SpecialThanks" target:self];
	}

	return _specifiers;
}

@end

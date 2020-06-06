#import "RFAppearanceSettings.h"

@implementation RFAppearanceSettings
- (NSUInteger)largeTitleStyle {
    return 2;
}

- (UIColor *)navigationBarTintColor {
	return [UIColor whiteColor];
}

- (UIColor *)navigationBarBackgroundColor {
	return [UIColor colorWithRed: 0.29 green: 0.35 blue: 0.60 alpha: 1.00];
}

- (UIColor *)navigationBarTitleColor {
	return [UIColor whiteColor];
}

- (UIColor *)statusBarTintColor {
	return [UIColor whiteColor];
}
@end
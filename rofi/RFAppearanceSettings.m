#import "RFAppearanceSettings.h"

@implementation RFAppearanceSettings
- (NSUInteger)largeTitleStyle {
    return 2;
}

- (UIColor *)navigationBarTintColor {
	return [UIColor whiteColor];
}

- (UIColor *)navigationBarBackgroundColor {
	return [UIColor colorWithRed: 0.57 green: 0.37 blue: 0.92 alpha: 1.00];
}

- (UIColor *)navigationBarTitleColor {
	return [UIColor whiteColor];
}

- (UIColor *)statusBarTintColor {
	return [UIColor whiteColor];
}
@end
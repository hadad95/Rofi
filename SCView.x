#import "SCView.h"

@implementation SCView
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	NSLog(@"self = %@", self);
	if (self) {
		self.backgroundColor = UIColor.grayColor;
		CAShapeLayer * maskLayer = [CAShapeLayer layer];
		maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){10.0, 10.}].CGPath;
		self.layer.mask = maskLayer;
	}
	return self;
}
@end
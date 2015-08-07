//
//  UIFactory.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "UIFactory.h"
#import "UIButton+ScaledImage.h"

@implementation UIFactory

+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font size:(CGSize)size {
#if defined (__IPHONE_7_0)
	return [string boundingRectWithSize:size
								options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
							 attributes:@{NSFontAttributeName: font}
								context:nil].size;
#else
	return [string sizeWithFont:font constrainedToSize:size];
#endif
}

+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font {
	return [self sizeForString:string font:font size:[UIScreen mainScreen].bounds.size];
}

+ (UIButton *)buttonWithTitle:(NSString *)title font:(UIFont *)font target:(id)target action:(SEL)action {
	CGSize size = [self sizeForString:title font:font];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = (CGRect){CGPointZero, size};
	button.titleLabel.font = font;
	button.titleLabel.numberOfLines = 0;
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+ (UIButton *)buttonWithImageName:(NSString *)imageName target:(id)target action:(SEL)action {
	UIImage *image = [UIImage imageNamed:imageName];
	CGFloat ratio = [UIScreen mainScreen].bounds.size.width / 320;
	CGSize size = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = (CGRect){CGPointZero, size};
	[button setScaledImage:image forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+ (UILabel *)labelWithString:(NSString *)string font:(UIFont *)font size:(CGSize)size {
	CGSize estimatedSize = [self sizeForString:string font:font size:size];
	UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, estimatedSize}];
	[label setNumberOfLines:0];
	[label setText:string];
	[label setFont:font];
	[label setBackgroundColor:[UIColor clearColor]];
	return label;
}

@end

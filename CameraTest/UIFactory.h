//
//  UIFactory.h
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import <UIKit/UIKit.h>

#define font(s) [UIFont systemFontOfSize:s]

@interface UIFactory : NSObject

+ (UIButton *)buttonWithTitle:(NSString *)title font:(UIFont *)font target:(id)target action:(SEL)action;
+ (UIButton *)buttonWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
+ (UILabel *)labelWithString:(NSString *)string font:(UIFont *)font size:(CGSize)size;

@end

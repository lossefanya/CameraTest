//
//  UIButton+ScaledImage.h
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ScaledImage)

- (void)setScaledImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)scaledImage:(UIImage *)image;
- (CGFloat)width;
- (CGFloat)height;

@end

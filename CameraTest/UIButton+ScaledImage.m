//
//  UIButton+ScaledImage.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "UIButton+ScaledImage.h"

@implementation UIButton (ScaledImage)

- (void)setScaledImage:(UIImage *)image forState:(UIControlState)state {
	[self setImage:[self scaledImage:image] forState:state];
}

- (UIImage *)scaledImage:(UIImage *)image {
	CGFloat imageRatio = image.size.width / image.size.height;
	CGFloat buttonRatio = self.frame.size.width / self.frame.size.height;
	CGFloat scaleFactor = (imageRatio > buttonRatio ? image.size.width / self.frame.size.width : image.size.height / self.frame.size.height);
	UIImage *scaledImg = [UIImage imageWithCGImage:[image CGImage] scale:scaleFactor orientation:UIImageOrientationUp];
	return scaledImg;
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (CGFloat)height {
	return self.frame.size.height;
}

@end

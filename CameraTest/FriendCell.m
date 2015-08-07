//
//  FriendCell.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "FriendCell.h"
#import "UIButton+ScaledImage.h"

@implementation FriendCell

- (void)awakeFromNib {
	// Initialization code
	[self.toggle setScaledImage:[UIImage imageNamed:@"userbutton_statusgreen_shadow"] forState:UIControlStateNormal];
	[self.toggle setScaledImage:[UIImage imageNamed:@"userbutton_statusgreen_selected"] forState:UIControlStateSelected];
	self.toggle.userInteractionEnabled = NO;
}

- (IBAction)toggleSelection:(id)sender {
	self.toggle.selected = !self.toggle.selected;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self layoutIfNeeded];
	self.imageView.layer.cornerRadius = self.imageView.frame.size.width * .5;
	self.imageView.clipsToBounds = YES;
}

@end

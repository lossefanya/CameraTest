//
//  OverlayView.h
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *imagePicker;

@end

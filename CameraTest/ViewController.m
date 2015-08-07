//
//  ViewController.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "ViewController.h"
#import "OverlayView.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *cameraButton;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)showCamera:(id)sender {
	OverlayView *overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	UIImagePickerController *imagePicker = [UIImagePickerController new];
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.showsCameraControls = NO;
	imagePicker.cameraOverlayView = overlayView;
	imagePicker.delegate = overlayView;
	imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0);
	imagePicker.cameraViewTransform = CGAffineTransformScale(imagePicker.cameraViewTransform, 1.333333, 1.333333);
	overlayView.imagePicker = imagePicker;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

@end

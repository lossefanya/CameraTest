//
//  OverlayView.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "OverlayView.h"
#import "FriendCell.h"
#import "FriendsSelectionFooter.h"
#import "FriendsSelectView.h"
#import "UIButton+ScaledImage.h"
#import "UIFactory.h"

typedef NS_ENUM(NSUInteger, HYCameraFlashMode) {
	HYCameraFlashModeAuto = 0,
	HYCameraFlashModeOn,
	HYCameraFlashModeOff,
};

@interface OverlayView () {
	CGPoint _previousPoint;
	HYCameraFlashMode _flashMode;
}

@property (nonatomic, strong) NSArray *flashImageNames;
@property (nonatomic, strong) NSMutableSet *selectedFriends;
@property (nonatomic, weak) UIImageView *resultView;
@property (nonatomic, weak) FriendsSelectView *friendsView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *leftButton;
@property (nonatomic, weak) UIButton *centerButton;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic) BOOL hasTakenPicture;
@property (nonatomic) BOOL isShowingControl;

@end

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self viewDidLoad];
	}
	return self;
}

- (void)viewDidLoad {
	//Datas
	self.selectedFriends = [NSMutableSet set];
	self.flashImageNames = @[@"flashauto", @"flash_on", @"flashoff"];
	
	//UI components initialization
	UIImageView *resultView = [[UIImageView alloc] initWithFrame:self.bounds];
	resultView.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:resultView];
	self.resultView = resultView;
	
	UIButton *closeButton = [UIFactory buttonWithImageName:@"close_camerascreen" target:self action:@selector(closeCamera)];
	[self addSubview:closeButton];
	self.closeButton = closeButton;
	
	UIButton *leftButton = [UIFactory buttonWithImageName:@"switchcamera" target:self action:@selector(switchCamera)];
	[self addSubview:leftButton];
	self.leftButton = leftButton;
	
	UIButton *centerButton = [UIFactory buttonWithImageName:@"shutterbutton" target:self action:@selector(takePicture)];
	[self addSubview:centerButton];
	self.centerButton = centerButton;
	
	UIButton *rightButton = [UIFactory buttonWithImageName:@"flashauto" target:self action:@selector(toggleFlash)];
	[self addSubview:rightButton];
	self.rightButton = rightButton;
	
	self.friendsView = [FriendsSelectView addFriendsSelectViewOnView:self];
	[self.friendsView setDidChangeSelection:^(NSSet *selectedFriends) {
		if (selectedFriends.count > 0) {
			[self.centerButton setScaledImage:[UIImage imageNamed:@"send_active"] forState:UIControlStateNormal];
		} else {
			[self.centerButton setScaledImage:[UIImage imageNamed:@"send_inactive"] forState:UIControlStateNormal];
		}
	}];
	[self.friendsView setDidHideFriendsSelectView:^{
		[self bounce:^(BOOL finished) {
			[self.leftButton setScaledImage:[UIImage imageNamed:@"switchcamera"] forState:UIControlStateNormal];
			[self.centerButton setScaledImage:[UIImage imageNamed:@"shutterbutton"] forState:UIControlStateNormal];
			[self.rightButton setScaledImage:[UIImage imageNamed:self.flashImageNames[_flashMode]] forState:UIControlStateNormal];
		}];
		if (!self.isShowingControl) {
			[self showControls:nil];
		}
		self.hasTakenPicture = NO;
		self.resultView.image = nil;
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}];
	[self.friendsView setDidFoldFriendsSelectView:^{
		[self showControls:nil];
	}];
	[self.friendsView setWillExpandFriendsSelectView:^{
		[self hideControls:nil];
	}];
	
	[self layoutButtons];
}

#pragma mark - Layout

- (void)layoutButtons {
	self.closeButton.center = CGPointMake(40, 40);
	self.leftButton.center = CGPointMake(34 + self.leftButton.width * .5, self.frame.size.height - self.leftButton.height * .5 - 43);
	self.centerButton.center = CGPointMake(self.frame.size.width * .5, self.frame.size.height - self.centerButton.height * .5 - 34);
	self.rightButton.center = CGPointMake(self.frame.size.width - self.rightButton.width * .5 - 34, self.frame.size.height - self.rightButton.height * .5 - 43);
}

#pragma mark - Event handlers

- (void)panSelectionView:(UIPanGestureRecognizer *)sender {
	CGPoint point = [sender translationInView:self];
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			_previousPoint = point;
			break;
		case UIGestureRecognizerStateChanged:{
			
			//move
			CGFloat move = point.y - _previousPoint.y;
			_previousPoint = point;
			CGRect frame = self.friendsView.frame;
			if (frame.origin.y + move > 64) {
				move = 64 - frame.origin.y;
			}
			self.friendsView.frame = CGRectOffset(frame, 0, move);
			
			CGPoint v = [sender velocityInView:self];
			
			//swipe
			if (v.y > 1000 || (v.y > 0 && frame.origin.y + frame.size.height > self.frame.size.height * .6)) {
				[self hideControls:^(BOOL finished) {
					[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
						UICollectionView *friendsView = self.friendsView;
						friendsView.frame = CGRectMake(0, 64, friendsView.frame.size.width, friendsView.frame.size.height);
					} completion:nil];
				}];
			} else if (v.y < -1000 || (v.y < 0 && frame.origin.y + frame.size.height < self.frame.size.height * .8)) {
				[UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					UICollectionView *friendsView = self.friendsView;
					friendsView.frame = CGRectMake(0, - friendsView.frame.size.height + 200, friendsView.frame.size.width, friendsView.frame.size.height);
				} completion:^(BOOL finished) {
					[self showControls:nil];
				}];
			}
			
			break;
		}
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			break;
		default:
			break;
	}
}

- (void)scrollToBottom {
	CGFloat height = _friendsView.collectionViewLayout.collectionViewContentSize.height;
	[_friendsView setContentOffset:CGPointMake(0, height - _friendsView.frame.size.height) animated:NO];
}

- (void)selectAll {
	NSInteger count = [self.friendsView numberOfItemsInSection:0];
	if (self.selectedFriends.count == count) {
		[self.centerButton setScaledImage:[UIImage imageNamed:@"send_inactive"] forState:UIControlStateNormal];
		[self.selectedFriends removeAllObjects];
	} else {
		[self.centerButton setScaledImage:[UIImage imageNamed:@"send_active"] forState:UIControlStateNormal];
		for (NSInteger i = 0; i < count; i++) {
			[self.selectedFriends addObject:@(i)];
		}
	}
	[self.friendsView reloadData];
}

- (void)backToCamera {
	[self.friendsView hideFriendsSelectView];
}

- (void)closeCamera {
	[self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchCamera {
	if (self.hasTakenPicture) {
		[self backToCamera];
	} else {
		self.imagePicker.cameraDevice = !self.imagePicker.cameraDevice;
	}
}

- (void)takePicture {
	if (!self.hasTakenPicture) {
		[self.imagePicker takePicture];
	}
}

- (void)toggleFlash {
	if (!self.hasTakenPicture) {
		_flashMode = (_flashMode + 1) % 3;
		if (_flashMode == HYCameraFlashModeOff) {
			self.imagePicker.cameraFlashMode = -1;
		} else {
			self.imagePicker.cameraFlashMode = (NSInteger)_flashMode;
		}
		[self.rightButton setScaledImage:[UIImage imageNamed:self.flashImageNames[_flashMode]] forState:UIControlStateNormal];
	}
}

#pragma mark - Animations

- (void)bounce:(void (^)(BOOL finished))completion {
	CGFloat bounce = 20;
	[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.leftButton.frame = CGRectOffset(self.leftButton.frame, 0, bounce);
		self.centerButton.frame = CGRectOffset(self.centerButton.frame, 0, bounce);
		self.rightButton.frame = CGRectOffset(self.rightButton.frame, 0, bounce);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.leftButton.frame = CGRectOffset(self.leftButton.frame, 0, -bounce);
			self.centerButton.frame = CGRectOffset(self.centerButton.frame, 0, -bounce);
			self.rightButton.frame = CGRectOffset(self.rightButton.frame, 0, -bounce);
		} completion:completion];
	}];
}

- (void)showControls:(void (^)(BOOL finished))completion {
	self.isShowingControl = YES;
	[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self layoutButtons];
	} completion:completion];
}

- (void)hideControls:(void (^)(BOOL finished))completion {
	self.isShowingControl = NO;
	CGFloat bounce = 20;
	CGFloat move = 140;
	[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.leftButton.frame = CGRectOffset(self.leftButton.frame, 0, -bounce);
		self.centerButton.frame = CGRectOffset(self.centerButton.frame, 0, -bounce);
		self.rightButton.frame = CGRectOffset(self.rightButton.frame, 0, -bounce);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.leftButton.frame = CGRectOffset(self.leftButton.frame, 0, move);
			self.centerButton.frame = CGRectOffset(self.centerButton.frame, 0, move);
			self.rightButton.frame = CGRectOffset(self.rightButton.frame, 0, move);
		} completion:completion];
	}];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	self.resultView.image = image;
	
	[self bounce:^(BOOL finished) {
		[self.leftButton setScaledImage:[UIImage imageNamed:@"retake"] forState:UIControlStateNormal];
		[self.centerButton setScaledImage:[UIImage imageNamed:@"send_inactive"] forState:UIControlStateNormal];
		[self.rightButton setScaledImage:[UIImage imageNamed:@"addtext"] forState:UIControlStateNormal];
	}];
	self.hasTakenPicture = YES;
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[self.friendsView showFriendsSelectView];
}


@end

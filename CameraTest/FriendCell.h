//
//  FriendCell.h
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *toggle;

- (IBAction)toggleSelection:(id)sender;

@end

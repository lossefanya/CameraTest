//
//  FriendsSelectView.h
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsSelectView : UICollectionView

@property (nonatomic, weak) UIView *topBar;
@property (nonatomic, strong) void (^didChangeSelection)(NSSet *selectedFriends);
@property (nonatomic, strong) void (^didHideFriendsSelectView)(void);
@property (nonatomic, strong) void (^didFoldFriendsSelectView)(void);
@property (nonatomic, strong) void (^willExpandFriendsSelectView)(void);

+ (FriendsSelectView *)addFriendsSelectViewOnView:(UIView *)parentView;
- (void)showFriendsSelectView;
- (void)hideFriendsSelectView;

@end

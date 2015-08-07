//
//  FriendsSelectView.m
//  CameraTest
//
//  Created by Young One Park on 2015. 8. 7..
//  Copyright (c) 2015년 young1park. All rights reserved.
//

#import "FriendsSelectView.h"
#import "FriendCell.h"
#import "FriendsSelectionFooter.h"
#import "UIFactory.h"

#define STATUS_BAR_HEIGHT 20
#define TOP_BAR_HEIGHT 64

@interface FriendsSelectView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGPoint previousPoint;
@property (nonatomic, strong) NSMutableSet *selectedFriends;

@end

@implementation FriendsSelectView

+ (FriendsSelectView *)addFriendsSelectViewOnView:(UIView *)parentView {
	CGFloat topBarHeight = TOP_BAR_HEIGHT;
	FriendsSelectView *selectView = [[FriendsSelectView alloc] initWithFrame:CGRectMake(0,
																						- parentView.frame.size.height + topBarHeight,
																						parentView.frame.size.width,
																						parentView.frame.size.height - topBarHeight)];
	UIView *topBar = [selectView newTopBar];
	[parentView addSubview:selectView];
	[parentView addSubview:topBar];
	selectView.topBar = topBar;
	return selectView;
}

- (id)initWithFrame:(CGRect)frame {
	UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
	layout.sectionInset = UIEdgeInsetsMake(44, 44, 44, 44);
	layout.minimumInteritemSpacing = 10.0f;
	layout.minimumLineSpacing = 10.0f;
	layout.footerReferenceSize = CGSizeMake(self.frame.size.width, 44);
	self = [super initWithFrame:frame collectionViewLayout:layout];
	if (self) {
		self.selectedFriends = [NSMutableSet set];
		self.backgroundColor = [UIColor whiteColor];
		self.dataSource = self;
		self.delegate = self;
		[self registerClass:[FriendCell class] forCellWithReuseIdentifier:@"FriendCell"];
		[self registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellWithReuseIdentifier:@"FriendCell"];
		[self registerClass:[FriendsSelectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FriendsSelectionFooter"];
		[self registerNib:[UINib nibWithNibName:@"FriendsSelectionFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FriendsSelectionFooter"];
	}
	return self;
}

- (UIView *)newTopBar {
	CGFloat topBarHeight = TOP_BAR_HEIGHT;
	CGFloat middle = (topBarHeight - STATUS_BAR_HEIGHT) / 2 + STATUS_BAR_HEIGHT;
	
	UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, -topBarHeight, self.frame.size.width, topBarHeight)];
	topBar.backgroundColor = [UIColor whiteColor];
	
	UIButton *backButton = [UIFactory buttonWithImageName:@"backbutton_topbar" target:self action:@selector(back)];
	backButton.center = CGPointMake(40, middle);
	[topBar addSubview:backButton];
	
	UILabel *label = [UIFactory labelWithString:@"Select friends" font:font(20) size:topBar.frame.size];
	label.center = CGPointMake(self.frame.size.width * .5, middle);
	[topBar addSubview:label];
	
	UIButton *allButton = [UIFactory buttonWithTitle:@"All" font:font(20) target:self action:@selector(selectAll)];
	allButton.frame = CGRectMake(0, 0, 44, 44);
	allButton.center = CGPointMake(self.frame.size.width - 40, middle);
	[topBar addSubview:allButton];
	
	UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, topBarHeight, self.frame.size.width, 2)];
	shadow.image = [UIImage imageNamed:@"topbar-shadow"];
	[topBar addSubview:shadow];
	
	return topBar;
}

#pragma mark - Event handlers

- (void)scrollToBottom {
	CGFloat height = self.collectionViewLayout.collectionViewContentSize.height;
	self.contentOffset = CGPointMake(0, height - self.frame.size.height);
}

- (void)showFriendsSelectView {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	[self topBarHidden:NO];
	[self scrollToBottom];
	[UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.frame = (CGRect){CGPointMake(0, -self.frame.size.height + 200), self.frame.size};
	} completion:nil];
}

- (void)hideFriendsSelectView {
	[self back];
}

- (void)back {
	[self topBarHidden:YES];
	[UIView animateWithDuration:.3 animations:^{
		self.frame = (CGRect){CGPointMake(0, -self.frame.size.height), self.frame.size};
	}];
	[self.selectedFriends removeAllObjects];
	[self reloadData];
	self.didHideFriendsSelectView();
}

- (void)selectAll {
	NSInteger count = [self numberOfItemsInSection:0];
	if (self.selectedFriends.count == count) {
		[self.selectedFriends removeAllObjects];
		self.didChangeSelection(self.selectedFriends);
	} else {
		for (NSInteger i = 0; i < count; i++) {
			[self.selectedFriends addObject:@(i)];
		}
		self.didChangeSelection(self.selectedFriends);
	}
	[self reloadData];
}

- (void)panSelectionView:(UIPanGestureRecognizer *)sender {
	CGPoint point = [sender translationInView:self];
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			self.previousPoint = point;
			break;
		case UIGestureRecognizerStateChanged:{
			
			//move
			CGFloat move = point.y - self.previousPoint.y;
			self.previousPoint = point;
			CGRect frame = self.frame;
			if (frame.origin.y + move > 64) {
				move = 64 - frame.origin.y;
			}
			self.frame = CGRectOffset(frame, 0, move);
			
			CGPoint v = [sender velocityInView:self];
			
			//swipe
			if (v.y > 1000 || (v.y > 0 && frame.origin.y + frame.size.height > self.frame.size.height * .6)) {
				self.willExpandFriendsSelectView();
				//				[self hideControls:^(BOOL finished) {
				[UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					self.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height);
				} completion:nil];
				//				}];
			} else if (v.y < -1000 || (v.y < 0 && frame.origin.y + frame.size.height < self.frame.size.height * .8)) {
				[UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
					self.frame = CGRectMake(0, - self.frame.size.height + 200, self.frame.size.width, self.frame.size.height);
				} completion:^(BOOL finished) {
					self.didFoldFriendsSelectView();
					//					[self showControls:nil];
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

#pragma mark - Animations

- (void)topBarHidden:(BOOL)isHidden {
	[UIView animateWithDuration:.4 animations:^{
		self.topBar.frame = (CGRect){CGPointMake(0, -64 * isHidden), self.topBar.frame.size};
	}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 40;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FriendCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
	[cell.contentView setClipsToBounds:YES];
	cell.imageView.image = [UIImage imageNamed:@"moretz"];
	cell.toggle.selected = [self.selectedFriends containsObject:@(indexPath.row)];
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if (kind == UICollectionElementKindSectionFooter) {
		FriendsSelectionFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
																			withReuseIdentifier:@"FriendsSelectionFooter"
																				   forIndexPath:indexPath];
		if (footer.gestureRecognizers == 0) {
			UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSelectionView:)];
			[footer addGestureRecognizer:pan];
		}
		return footer;
	}
	return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	FriendCell *cell = (FriendCell *)[collectionView cellForItemAtIndexPath:indexPath];
	cell.toggle.selected = !cell.toggle.selected;
	if (cell.toggle.selected) {
		[self.selectedFriends addObject:@(indexPath.row)];
	} else {
		[self.selectedFriends removeObject:@(indexPath.row)];
	}
	
	self.didChangeSelection(self.selectedFriends);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
	if (elementKind == UICollectionElementKindSectionFooter && collectionView.frame.origin.y > 0) {
	}
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat size = 62.f / 320.f * self.frame.size.width;
	return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	CGFloat inset = 20.f / 320.f * self.frame.size.width;
	return UIEdgeInsetsMake(inset, inset, inset, inset);
}



@end

//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDCollectionViewEmbeddedInTableViewCellRender.h"

@implementation GDDCollectionViewEmbeddedInTableViewCellRender {

}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.contentView addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"H:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view" : _collectionView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"V:|-0-[view]" options:0 metrics:nil views:@{@"view" : _collectionView}]];

    _collectionView.backgroundColor = [UIColor clearColor];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView.showsHorizontalScrollIndicator = NO;

    // 设置每一个cell的固定高度和宽度
    CGFloat height = 150.0;
    CGFloat width = 100.0; //self.contentView.frame.size.width;
    flowLayout.itemSize = CGSizeMake(width, height);
//    flowLayout.estimatedItemSize = CGSizeMake(1, 1);
    [_collectionView addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
  }
  return self;
}

- (Class <GDDPresenter>)presenterClass {
  return nil;
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
  // With autolayout enabled on collection view's cells we need to force a collection view relayout with the shown size (width)
  self.collectionView.frame = CGRectMake(0, 0, targetSize.width, MAXFLOAT);
  [self.collectionView layoutIfNeeded];

  // If the cell's size has to be exactly the content
  // Size of the collection View, just return the
  // collectionViewLayout's collectionViewContentSize.
  return [self.collectionView.collectionViewLayout collectionViewContentSize];
}
@end
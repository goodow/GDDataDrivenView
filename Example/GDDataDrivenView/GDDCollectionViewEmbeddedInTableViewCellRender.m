//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDCollectionViewEmbeddedInTableViewCellRender.h"


@implementation GDDCollectionViewEmbeddedInTableViewCellRender
- (Class <GDDPresenter>)presenterClass {
  return nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) collectionViewLayout:flowLayout];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];

    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_collectionView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"H:|-0-[view]-0-|"                                                  options:0 metrics:nil views:@{@"view" : _collectionView}]];

    flowLayout.itemSize = CGSizeMake(100, 100);
  }

  return self;
}

- (void)updateConstraints {
  [super updateConstraints];
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
      @"V:|-0-[view(300)]"                                                 options:0 metrics:nil views:@{@"view" : _collectionView}]];
//  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
//      @"V:[view(300)]" options:0 metrics:nil views:@{@"view" : self.contentView}]];
}

@end
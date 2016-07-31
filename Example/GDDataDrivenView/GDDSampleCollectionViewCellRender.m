//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDSampleCollectionViewCellRender.h"


@implementation GDDSampleCollectionViewCellRender {

}
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    [self addSubview:_imageView];

//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
//        @"H:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view" : _collectionView}]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
//        @"V:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view" : _collectionView}]];
  }

  return self;
}

- (Class <GDDPresenter>)presenterClass {
  return nil;
}

@end
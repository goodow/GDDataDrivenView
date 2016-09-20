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
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"H:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view" : _imageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"V:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view" : _imageView}]];
  }
  return self;
}

@end
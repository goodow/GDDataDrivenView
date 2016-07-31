//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDSampleCollectionViewCellPresenter.h"
#import "GDDSampleCollectionViewCellRender.h"


@implementation GDDSampleCollectionViewCellPresenter {

}

- (void)update:(GDDSampleCollectionViewCellRender *)render withModel:(GDDModel *)model {
  NSString *image = model.data;
  render.imageView.image = [UIImage imageNamed:image];
}

@end
//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDDRender.h"

@class GDDCollectionViewLayout;

@interface GDDCollectionViewEmbeddedInTableViewCellRender : UITableViewCell <GDDRender>
@property(nonatomic, readonly) UICollectionView *collectionView;
@end
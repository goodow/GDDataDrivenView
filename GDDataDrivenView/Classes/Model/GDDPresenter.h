//
// Created by Larry Tin on 7/17/16.
//

#import <Foundation/Foundation.h>
#import "GDDModel.h"

@protocol GDDRender;

@protocol GDDPresenter

- (void)update:(id<GDDRender>)render withModel:(GDDModel *)model;

@optional
- (instancetype)initWithOwnerView:(id)ownerView;

@end
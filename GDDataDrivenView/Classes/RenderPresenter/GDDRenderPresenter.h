//
// Created by Larry Tin on 7/17/16.
//

#import <Foundation/Foundation.h>
#import "GDDPresenter.h"
@protocol GDDRender;

@protocol GDDRenderPresenter <GDDPresenter>

- (void)update:(id <GDDRender>)render withData:(id)data;

@optional
- (instancetype)initWithOwner:(id)owner;

@end
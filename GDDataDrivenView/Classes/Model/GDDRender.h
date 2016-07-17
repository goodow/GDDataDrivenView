//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDDPresenter.h"

@protocol GDDRender

@optional
- (id <GDDPresenter>)presenter;

- (void)handleData:(id)data;
@end
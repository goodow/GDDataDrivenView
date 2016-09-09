//
// Created by Larry Tin on 7/17/16.
//

#import <Foundation/Foundation.h>

@protocol GDDRender;

@protocol GDDPresenter

- (void)update:(id <GDDRender>)render withData:(id)data;

@optional
/**
 * @param owner 使用弱引用持有, 否则将导致循环引用
 * @return
 */
- (instancetype)initWithOwner:(id)owner;

@end
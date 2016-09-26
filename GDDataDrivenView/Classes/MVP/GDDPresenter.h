//
// Created by Larry Tin on 16/9/20.
//

#import <Foundation/Foundation.h>
@protocol GDDView;

@protocol GDDPresenter

- (void)update:(id <GDDView>)view withData:(id)data;

@optional
/**
 * @param owner 使用弱引用持有, 否则将导致循环引用
 * @return
 */
- (instancetype)initWithOwner:(id)owner;

@end
//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDDPresenter.h"

@protocol GDDRender

@optional
/**
 * @return 当不实现该方法时, 默认根据类名约定查找并复用之前已创建的 Presenter 实例, 若不存在则创建新的实例并缓存
 *
 *   AbcRender -> AbcPresenter
 *   XyzViewController -> XyzPresenter
 *
 */
- (id <GDDPresenter>)presenter;

@end
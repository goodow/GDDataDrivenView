//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDDPresenter.h"

@protocol GDDRender

/**
 * @return 若返回nil, 则使用命名约定: AbcRender -> AbcPresenter
 */
- (Class <GDDPresenter>)presenterClass;

@end
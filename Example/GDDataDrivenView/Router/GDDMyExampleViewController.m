//
// Created by Larry Tin on 1/1/18.
// Copyright (c) 2018 Larry Tin. All rights reserved.
//

#import "GDDMyExampleViewController.h"
#import "UIViewController+GDDataDrivenView.h"

/**
 * 在头文件中声明实现 <GDDView> 协议
 */
@implementation GDDMyExampleViewController {

}

/**
 * 一般交由框架自动创建 View Controller, 并调用该方法完成初始化
 * @return
 */
- (instancetype)init {
  if (self = [super init]) {
    // 指定默认的视图配置
    super.viewOption.setSupportedInterfaceOrientations(UIInterfaceOrientationMaskPortrait)
        .setHidesBottomBarWhenPushed(YES);
  }
  return self;
}

/*
 * 当不希望使用约定的命名规则, 或需要自行创建 Presenter 时, 实现 GDDView 的该可选方法.
 *
 * 一种常见写法是直接返回 self, 并在头文件中声明同时实现 <GDDView, GDDPresenter> 协议,
 * 然后实现 -[GDDPresenter update:withData:] 方法以接收数据.
 * 这种情况下 View Controller 将兼任 View 和 Presenter 两种角色.
 *
  - (id <GDDPresenter>)presenter {
    return self;
  }
*/

@end
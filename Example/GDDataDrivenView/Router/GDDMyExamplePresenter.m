//
// Created by Larry Tin on 1/1/18.
// Copyright (c) 2018 Larry Tin. All rights reserved.
//

#import "GDDMyExamplePresenter.h"
#import "GDDMyExampleViewController.h"
#import "ViewModel.pbobjc.h"

/**
 * 在头文件中声明实现 <GDDPresenter> 协议.
 *
 * GDDMyExampleViewController 对应的 Presenter 默认为 GDDMyExamplePresenter, 使用命名约定以避免额外配置.
 *
 * 该类的对象一般由框架自动创建, 若实现了 @selector(initWithOwner:), 则会调用该方法完成初始化;
 * 否则使用 @selector(init) 初始化
 */
@interface GDDMyExamplePresenter ()
@property (weak) GDDMyExampleViewController *viewController;
@end

@implementation GDDMyExamplePresenter {

}

/**
 * 当需要接收 Presenter 对应的 View Controller 对象时, 可实现该可选方法
 * @param owner 必须使用弱引用持有 owner
 * @return
 */
- (instancetype)initWithOwner:(GDDMyExampleViewController *)owner {
  self = [super init];
  if (self) {
    _viewController = owner;

    /**
    在这里给 _viewController 挂载事件处理回调, 实现 Presenter 单向依赖 View Controller

    [_viewController addPullToRefreshWithActionHandler:^{

    }];

    **/
  }
  return self;
}

/**
 *
 * @param viewController 该 Presenter 对应的 View Controller, 一般和 owner 一样.
 * @param viewModel 如果跳转时传递的参数是字典类弱类型, 只要存在类名为 GDDMyExampleViewModel 的强类型,
 * 框架会自动将字典转换为该强类型. 否则, 直接传递原始数据对象.
 */
- (void)update:(GDDMyExampleViewController *)viewController withData:(GDDMyExampleViewModel *)viewModel {
  // 使用数据模型 viewModel 更新界面 viewController
}

@end
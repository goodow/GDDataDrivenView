//
// Created by Larry Tin on 16/9/20.
//

#import <UIKit/UIKit.h>
@protocol GDDView;

@protocol GDDPresenter

/**
 * @param viewController viewDidLoad 这时已被调用
 * @param data
 */
- (void)update:(UIViewController<GDDView> *)viewController withData:(id)data;

@optional
/**
 * 必须在 UIViewController 的 init 初始化阶段创建 Presenter
 * @param owner 使用弱引用持有 owner, 否则将导致循环引用
 */
- (instancetype)initWithOwner:(id)owner;

@end

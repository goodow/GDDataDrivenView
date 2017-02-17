//
// Created by Larry Tin on 15/4/30.
//

#import <UIKit/UIKit.h>
#import "GDDPBExtrasOption+FluentInterface.h"
#import "GDDView.h"

@protocol GDDTransitionBuilder
enum GDDViewControllerTransitionStackMode {
  PUSH, PRESENT, PRESENT_THEN_PUSH
};

/**
 * 当不存在于历史堆栈中时, 使用该模式进行显示
 */
- (void (^)(enum GDDViewControllerTransitionStackMode stackMode))by;
/**
 * 作为 UIWindow 的 rootViewController
 */
- (void (^)())asRoot;

/**
 * 适用于 ViewController 已存在于历史堆栈中的情况
 */
- (void (^)(BOOL bringToFront))refresh;

@end

NS_ASSUME_NONNULL_BEGIN
@interface GDDViewControllerTransition : NSObject

- (GDDViewControllerTransition *(^)(id data))data;
- (GDDViewControllerTransition *(^)(GDDPBViewOption *viewOption))viewOption;

/**
 * 总是创建新的 ViewController 实例, 并显示
 */
- (id<GDDTransitionBuilder> (^)(Class viewControllerClass))toClass;
/**
 * 先检查历史堆栈中是否存在该类型的 ViewController, 若存在则回退至可见; 若不存在则先创建再显示
 */
- (id<GDDTransitionBuilder> (^)(Class viewControllerClass))toSingleton;
/**
 * 先检查历史堆栈中是否存在该 ViewController, 若存在则回退至可见; 若不存在则先创建再显示
 */
- (id<GDDTransitionBuilder> (^)(UIViewController *viewController))toInstance;

/**
 * 回到上一层, 并刷新
 */
- (void (^)())toUp;
/**
 * 刷新当前界面
 */
- (void (^)())toCurrent;

/**
 * @return 当前可见的 ViewController
 */
+ (UIViewController *)topViewController;

@end
NS_ASSUME_NONNULL_END

//
// Created by Larry Tin on 15/4/30.
//

#import <UIKit/UIKit.h>
#import "GoodowBool.pbobjc.h"
#import "GoodowExtrasOption.pbobjc.h"
#import "UIViewController+GDDataDrivenView.h"
#import "GDDView.h"

@protocol GDDTransitionBuilder
enum GDDViewControllerTransitionStackMode {
  PUSH, PRESENT, PRESENT_THEN_PUSH
};

- (void (^)(enum GDDViewControllerTransitionStackMode stackMode))by;
- (void (^)())asRoot;

- (void (^)(BOOL bringToFront))refresh;

@end

NS_ASSUME_NONNULL_BEGIN
@interface GDDViewControllerTransition : NSObject

- (GDDViewControllerTransition *(^)(id data))data;
- (GDDViewControllerTransition *(^)(GDDPBViewOption *viewOption))viewOption;

- (id<GDDTransitionBuilder> (^)(Class viewControllerClass))to;
- (id<GDDTransitionBuilder> (^)(Class viewControllerClass))toSingleton;
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
 * 返回当前可见的 View Controller
 * @return
 */
+ (UIViewController *)topViewController;

@end
NS_ASSUME_NONNULL_END

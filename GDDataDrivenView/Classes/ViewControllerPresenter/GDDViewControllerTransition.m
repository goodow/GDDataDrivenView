//
// Created by Larry Tin on 15/4/30.
//

#import "GDDViewControllerTransition.h"
#import <objc/runtime.h>
#import "UIViewController+GDDataDrivenView.h"

@interface GDDViewControllerTransition () <GDDTransitionBuilder>
@end

@implementation GDDViewControllerTransition {
  id _data;
  GDDPBViewOption *_viewOption;
  UIViewController *_viewController;
  enum GDDViewControllerTransitionStackMode _stackMode;
  BOOL _alreadyInStack; // 是否已经显示过了
  Class _viewControllerClass;
}

- (GDDViewControllerTransition *(^)(id data))data {
  return ^GDDViewControllerTransition *(id data) {
      _data = data;
      return self;
  };
}

- (GDDViewControllerTransition *(^)(GDDPBViewOption *viewOption))viewOption {
  return ^GDDViewControllerTransition *(GDDPBViewOption *viewOption) {
      _viewOption = viewOption;
      return self;
  };
}

- (id <GDDTransitionBuilder> (^)(Class viewControllerClass))toClass {
  return ^id <GDDTransitionBuilder>(Class viewControllerClass) {
      _viewControllerClass = viewControllerClass;
      return self;
  };
}

- (id <GDDTransitionBuilder> (^)(Class viewControllerClass))toSingleton {
  return ^id <GDDTransitionBuilder>(Class viewControllerClass) {
      UIViewController *found = [self.class findViewController:viewControllerClass];
      if (found) {
        _viewController = found;
        _alreadyInStack = YES;
        [self mergeViewOption];
      } else {
        _viewControllerClass = viewControllerClass;
      }
      return self;
  };
}

- (id <GDDTransitionBuilder> (^)(UIViewController *viewController))toInstance {
  return ^id <GDDTransitionBuilder>(UIViewController *viewController) {
      _viewController = viewController;
      _viewControllerClass = nil;
      [self mergeViewOption];
      UIViewController *found = [self.class find:viewController in:UIApplication.sharedApplication.keyWindow.rootViewController instanceOrClass:YES];
      if (found) {
        _alreadyInStack = YES;
      }
      return self;
  };
}

- (void (^)())toUp {
  return ^{
      _alreadyInStack = YES;
      _viewController = GDDViewControllerTransition.upViewController;
      [self mergeViewOption];
      [self displayAndRefresh];
  };
}

- (void (^)())toCurrent {
  return ^{
      _viewController = GDDViewControllerTransition.topViewController;
      [self mergeViewOption];
      [self updateData];
  };
}

- (void (^)(enum GDDViewControllerTransitionStackMode stackMode))by {
  return ^(enum GDDViewControllerTransitionStackMode stackMode) {
      _stackMode = stackMode;
      [self displayAndRefresh];
  };
}

- (void (^)())asRoot {
  return ^{
      UIViewController *controller = self.viewController;
      if (![controller isKindOfClass:UITabBarController.class] && ![controller isKindOfClass:UINavigationController.class]) {
        controller = [[UINavigationController alloc] initWithRootViewController:controller];
      }
      UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
      if (rootViewController.presentedViewController) { // 避免内存泄漏, 以释放 rootViewController 和 rootViewController.presentedViewController
        [rootViewController dismissViewControllerAnimated:_viewOption.animated != GDPBBool_False completion:nil];
      }
      UIWindow *window = UIApplication.sharedApplication.delegate.window;
      if (!window) {
        window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        window.rootViewController = controller;
        [window makeKeyAndVisible];
        UIApplication.sharedApplication.delegate.window = window;
      } else {
        window.rootViewController = controller; // 不能使用 keyWindow, 其在 makeKeyAndVisible 执行前为 nil
      }
      [self updateData];
  };
}

- (void (^)(BOOL bringToFront))refresh {
  return ^(BOOL bringToFront) {
      if (!bringToFront) {
        [self updateData];
        return;
      }

      // bring viewController to front
      UIViewController *controller = self.viewController;
      if (controller.presentedViewController) {
        [controller dismissViewControllerAnimated:_viewOption.animated != GDPBBool_False completion:nil];
      }
      UIViewController *current = controller;
      while (current.parentViewController) {
        if ([current.parentViewController isKindOfClass:UITabBarController.class]) {
          ((UITabBarController *) current.parentViewController).selectedViewController = current;
        } else if ([current.parentViewController isKindOfClass:UINavigationController.class]) {
          [((UINavigationController *) current.parentViewController) popToViewController:current animated:_viewOption.animated != GDPBBool_False];
        }
        current = current.parentViewController;
      }
      [self updateData];
  };
}

- (void)displayAndRefresh {
  if (_alreadyInStack) {
    self.refresh(YES);
    return;
  }

  UIViewController *controller = self.viewController;
  UIViewController *top = self.class.topViewController;
  BOOL shouldPush = _stackMode == PUSH && top.navigationController;
  /* config new controller */
  if (_viewOption) {
    if (_viewOption.edgesForExtendedLayout) { // 没法支持默认值UIRectEdgeNone
      controller.edgesForExtendedLayout = _viewOption.edgesForExtendedLayout;
    }
    controller.hidesBottomBarWhenPushed = _viewOption.hidesBottomBarWhenPushed;

    if (!shouldPush) {
      // 动画: 仅在 present 时有效
      controller.modalTransitionStyle = _viewOption.modalTransitionStyle;
      controller.modalPresentationStyle = _viewOption.modalPresentationStyle;
    }
  }

  if (shouldPush) {
    [top.navigationController pushViewController:controller animated:_viewOption.animated != GDPBBool_False];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self updateData];
    }];
    return;
  }

  [self config:YES]; // 某些 ViewOption 需要在 present 之前设置才会生效
  [top presentViewController:_stackMode == PRESENT ? controller : [[UINavigationController alloc] initWithRootViewController:controller] animated:_viewOption.animated != GDPBBool_False completion:nil];
  [self updateData];
}

- (void)updateData {
  [self config:NO];
  UIViewController *controller = self.viewController;
  if (![controller conformsToProtocol:@protocol(GDDView)]) {
    return;
  }
  if (!controller.isViewLoaded) {
    [controller view]; // force viewDidLoad to be called
  }
  [[(UIViewController <GDDView> *) controller presenter] update:controller withData:_data];
}

- (void)config:(BOOL)eagerly {
  UIViewController *controller = self.viewController;
  GDDPBViewOption *viewOption = self.viewController.viewOption;

  enum GDPBBool statusBar = viewOption.statusBar;
  if (statusBar != GDPBBool_Default && GDPBBool_IsValidValue(statusBar)) {
    [controller setNeedsStatusBarAppearanceUpdate];
  }
  if (eagerly) {
    return; // 在 presentViewController 前设置 navBar 无效
  }
  enum GDPBBool navBar = viewOption.navBar;
  if (navBar != GDPBBool_Default && GDPBBool_IsValidValue(navBar)) {
    BOOL shouldHidden = navBar == GDPBBool_False;
    [controller.navigationController setNavigationBarHidden:shouldHidden animated:viewOption.animated != GDPBBool_False];
    controller.navigationController.navigationBar.hidden = shouldHidden;
    controller.navigationController.navigationBar.barStyle = viewOption.navBarStyle;
  }
  enum GDPBBool tabBar = viewOption.tabBar;
  if (tabBar != GDPBBool_Default && GDPBBool_IsValidValue(tabBar)) {
    controller.tabBarController.tabBar.hidden = tabBar == GDPBBool_False;
  }
  enum GDPBBool toolBar = viewOption.toolBar;
  if (toolBar != GDPBBool_Default && GDPBBool_IsValidValue(toolBar)) {
    [controller.navigationController setToolbarHidden:toolBar == GDPBBool_False animated:viewOption.animated != GDPBBool_False];
  }
  enum GDPBBool navBarTranslucent = viewOption.navBarTranslucent;
  if (navBarTranslucent != GDPBBool_Default && GDPBBool_IsValidValue(navBarTranslucent)) {
    controller.navigationController.navigationBar.translucent = navBarTranslucent != GDPBBool_False;
  }
  if (viewOption.deviceOrientation) {
    viewOption.deviceOrientation = UIDeviceOrientationUnknown;
    [[UIDevice currentDevice] setValue:@(viewOption.deviceOrientation) forKey:@"orientation"];
  }
  if (viewOption.attemptRotationToDeviceOrientation) {
    viewOption.attemptRotationToDeviceOrientation = NO;
    [UIViewController attemptRotationToDeviceOrientation];
  }
}

- (UIViewController *)viewController {
  if (!_viewController) {
    _viewController = [[_viewControllerClass alloc] init];
    [self mergeViewOption];
  }
  return _viewController;
}

- (void)mergeViewOption {
//  if (![_viewController conformsToProtocol:@protocol(GDDView)]) {
//    return;
//  }
  GDDPBViewOption *viewOption = _viewController.viewOption;
  if (_viewOption) {
    [viewOption mergeFrom:_viewOption];
  }
  _viewOption = viewOption;
}

+ (UIViewController *)topViewController {
  return [self findTopViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
}

+ (UIViewController *)findTopViewController:(UIViewController *)parent {
  if (parent.presentedViewController && !parent.presentedViewController.isBeingDismissed) {
    return [self findTopViewController:parent.presentedViewController];
  }
  return [self findVisibleChildViewController:parent];
}

+ (UIViewController *)upViewController {
  UIViewController *current = self.topViewController;
  NSArray *navViewControllers = current.navigationController.viewControllers;
  if (navViewControllers.count > 1) {
    return navViewControllers[navViewControllers.count - 2];
  }
  if (current.presentingViewController) {
    return [self findVisibleChildViewController:current.presentingViewController];
  }

  while (current.parentViewController) {
    UIViewController *parent = current.parentViewController;
    if ([parent isMemberOfClass:UIPageViewController.class] || [parent isMemberOfClass:UINavigationController.class] ||
        [parent isMemberOfClass:UITabBarController.class]) { // skip system's view controllers
      current = parent;
      continue;
    }
    return parent;
  }
  return current;
}

+ (UIViewController *)findViewController:(Class)viewControllerClass {
  return [self find:(id) viewControllerClass in:UIApplication.sharedApplication.keyWindow.rootViewController instanceOrClass:NO];
}

+ (UIViewController *)find:(id)controllerOrClass in:(UIViewController *)parent instanceOrClass:(BOOL)isInstance {
  if (parent.presentedViewController) {
    UIViewController *found = [self find:controllerOrClass in:parent.presentedViewController instanceOrClass:isInstance];
    if (found) {
      return found;
    }
  }
  if ([parent isKindOfClass:UITabBarController.class]) {
    UITabBarController *tabBarController = (UITabBarController *) parent;
    NSMutableArray<UIViewController *> *viewControllers = tabBarController.viewControllers.mutableCopy;
    if (tabBarController.selectedIndex != 0) {
      UIViewController *selectedViewController = tabBarController.selectedViewController;
      [viewControllers removeObject:selectedViewController];
      [viewControllers insertObject:selectedViewController atIndex:0];
    }
    for (UIViewController *ctr in viewControllers) {
      UIViewController *found = [self find:controllerOrClass in:ctr instanceOrClass:isInstance];
      if (found) {
        return found;
      }
    }
    if ([self isSame:controllerOrClass with:tabBarController instanceOrClass:isInstance]) {
      return tabBarController;
    }
  } else if ([parent isKindOfClass:UINavigationController.class]) {
    UINavigationController *navigationController = (UINavigationController *) parent;
    for (UIViewController *ctr in navigationController.viewControllers.reverseObjectEnumerator) {
      UIViewController *found = [self find:controllerOrClass in:ctr instanceOrClass:isInstance];
      if (found) {
        return found;
      }
    }
    if ([self isSame:controllerOrClass with:navigationController instanceOrClass:isInstance]) {
      return navigationController;
    }
  } else if ([parent isKindOfClass:UIPageViewController.class]) {
    UIPageViewController *pageViewController = (UIPageViewController *) parent;
    for (UIViewController *ctr in pageViewController.viewControllers) {
      UIViewController *found = [self find:controllerOrClass in:ctr instanceOrClass:isInstance];
      if (found) {
        return found;
      }
    }
    if ([self isSame:controllerOrClass with:pageViewController instanceOrClass:isInstance]) {
      return pageViewController;
    }
  }
  return [self isSame:controllerOrClass with:parent instanceOrClass:isInstance] ? parent : nil;
}

+ (BOOL)isSame:(id)controllerOrClass with:(UIViewController *)otherController instanceOrClass:(BOOL)isInstance {
  return isInstance ? controllerOrClass == otherController : [otherController isKindOfClass:controllerOrClass];
}

+ (UIViewController *)findVisibleChildViewController:(UIViewController *)parent {
  UIViewController *child = [self getVisibleChildViewController:parent];
  return child ? [self findVisibleChildViewController:child] : parent;
}

+ (UIViewController *)getVisibleChildViewController:(UIViewController *)parent {
  if ([parent isKindOfClass:UINavigationController.class]) {
    return ((UINavigationController *) parent).topViewController;
  } else if ([parent isKindOfClass:UITabBarController.class]) {
    return ((UITabBarController *) parent).selectedViewController;
  } else if ([parent isKindOfClass:UIPageViewController.class]) {
    return ((UIPageViewController *) parent).viewControllers.firstObject;
  } else {
    return nil;
  }
}
@end
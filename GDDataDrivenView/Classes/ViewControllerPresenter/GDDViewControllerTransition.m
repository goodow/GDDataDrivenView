//
// Created by Larry Tin on 15/4/30.
//

#import "GDDViewControllerTransition.h"
#import <objc/runtime.h>

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kPresenterKey = 0;

@interface GDDViewControllerTransition () <GDDTransitionBuilder>
@end

@implementation GDDViewControllerTransition {
  id _data;
  GDDPBViewOption *_viewOption;
  UIViewController *_viewController;
  enum GDDViewControllerTransitionStackMode _stackMode;
  BOOL _alreadyInStack; // 是否已经显示过了
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

- (id <GDDTransitionBuilder> (^)(Class viewControllerClass))to {
  return ^id <GDDTransitionBuilder>(Class viewControllerClass) {
      _viewController = [[viewControllerClass alloc] init];
      return self;
  };
}

- (id <GDDTransitionBuilder> (^)(Class viewControllerClass))toSingleton {
  return ^id <GDDTransitionBuilder>(Class viewControllerClass) {
      UIViewController *found = [self.class findViewController:viewControllerClass];
      if (found) {
        _viewController = found;
        _alreadyInStack = YES;
        return self;
      } else {
        return self.to(viewControllerClass);
      }
  };
}

- (id <GDDTransitionBuilder> (^)(UIViewController *viewController))toInstance {
  return ^id <GDDTransitionBuilder>(UIViewController *viewController) {
      _viewController = viewController;
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
      _viewController = GDDViewControllerTransition.backViewController ?: GDDViewControllerTransition.topViewController;
      [self displayAndRefresh];
  };
}

- (void (^)())toCurrent {
  return ^{
      _viewController = GDDViewControllerTransition.topViewController;
      self.refresh(NO);
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
      UIViewController *controller = _viewController;
      if (![controller isKindOfClass:UITabBarController.class] && ![controller isKindOfClass:UINavigationController.class]) {
        _viewController = controller = [[UINavigationController alloc] initWithRootViewController:controller];
      }
      [GDDViewControllerTransition replaceRootViewController:controller];
      self.refresh(NO);
  };
}

- (void (^)(BOOL bringToFront))refresh {
  return ^(BOOL bringToFront) {
      UIViewController *controller = _viewController;
      if (!bringToFront) {
        [self config:NO];
        id <GDDPresenter> presenter = [self.class findOrCreatePresenterForViewController:controller];
        if (!controller.isViewLoaded) {
          [controller view]; // force viewDidLoad to be called
        }
        [presenter update:controller withData:_data];
        return;
      }

      // bring viewController to front
      void (^bringFoundToFront)() = ^{
          UIViewController *current = controller;
          while (current.parentViewController) {
            if ([current.parentViewController isKindOfClass:UITabBarController.class]) {
              ((UITabBarController *) current.parentViewController).selectedViewController = current;
            } else if ([current.parentViewController isKindOfClass:UINavigationController.class]) {
              [((UINavigationController *) current.parentViewController) popToViewController:current animated:YES];
            }
            current = current.parentViewController;
          }
          dispatch_async(dispatch_get_main_queue(), ^{
              self.refresh(NO);
          });
      };
      if (controller.presentedViewController) {
        [controller dismissViewControllerAnimated:YES completion:bringFoundToFront];
      } else {
        bringFoundToFront();
      }
  };
}

- (void)displayAndRefresh {
  if (_alreadyInStack) {
    self.refresh(YES);
    return;
  }

  UIViewController *controller = _viewController;
  id <GDDPresenter> presenter = [self.class findOrCreatePresenterForViewController:controller];

  UIViewController *top = self.class.topViewController;
  BOOL shouldPush = _stackMode == PUSH && top.navigationController;
  /* config new controller */
  if (_viewOption) {
    controller.edgesForExtendedLayout = _viewOption.edgesForExtendedLayout;
    controller.hidesBottomBarWhenPushed = _viewOption.hidesBottomBarWhenPushed;

    if (!shouldPush) {
      // 动画: 仅在 present 时有效
      controller.modalTransitionStyle = _viewOption.modalTransitionStyle;
      controller.modalPresentationStyle = _viewOption.modalPresentationStyle;
    }
  }

  if (shouldPush) {
    [top.navigationController pushViewController:controller animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self config:NO];
        if (!controller.isViewLoaded) {
          [controller view]; // force viewDidLoad to be called
        }
        [presenter update:controller withData:_data];
    });
    return;
  }

  [self config:YES]; // 某些 ViewOption 需要在 present 之前设置才会生效
  [top presentViewController:_stackMode == PRESENT ? controller : [[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
      [presenter update:controller withData:_data];
  }];
  [self config:NO];
}

- (void)config:(BOOL)eagerly {
  UIViewController *controller = _viewController;
  GDDPBViewOption *viewOption = controller.viewOption;
  if (_viewOption) {
    [viewOption mergeFrom:_viewOption];
  }

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
    [controller.navigationController setNavigationBarHidden:shouldHidden animated:NO];
    controller.navigationController.navigationBar.hidden = shouldHidden;
    controller.navigationController.navigationBar.barStyle = viewOption.navBarStyle;
  }
  enum GDPBBool tabBar = viewOption.tabBar;
  if (tabBar != GDPBBool_Default && GDPBBool_IsValidValue(tabBar)) {
    controller.tabBarController.tabBar.hidden = tabBar == GDPBBool_False;
  }
  enum GDPBBool toolBar = viewOption.toolBar;
  if (toolBar != GDPBBool_Default && GDPBBool_IsValidValue(toolBar)) {
    [controller.navigationController setToolbarHidden:toolBar == GDPBBool_False animated:NO];
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

+ (UIViewController *)topViewController {
  return [self findTopViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
}

+ (UIViewController *)findTopViewController:(UIViewController *)parent {
  if (parent.presentedViewController) {
    return [self findTopViewController:parent.presentedViewController];
  }
  UIViewController *child = [self getVisibleOrChildViewController:parent forceChild:NO];
  return child ? [self findTopViewController:child] : parent;
}

+ (UIViewController *)backViewController {
  UIViewController *top = GDDViewControllerTransition.topViewController;
  NSArray *navViewControllers = top.navigationController.viewControllers;
  if (navViewControllers.count > 1) {
    return navViewControllers[navViewControllers.count - 2];
  } else if (top.presentingViewController) {
    UIViewController *child = [self getVisibleOrChildViewController:top.presentingViewController forceChild:YES];
    return child ?: top.presentingViewController;
  }
  return nil;
}

+ (void)replaceRootViewController:(UIViewController *)controller {
  UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
  if (rootViewController.presentedViewController) { // 避免内存泄漏, 以释放 rootViewController 和 rootViewController.presentedViewController
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
  }
  UIApplication.sharedApplication.delegate.window.rootViewController = controller; // keyWindow 在 makeKeyAndVisible 执行前为nil
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

+ (UIViewController *)getVisibleOrChildViewController:(UIViewController *)parent forceChild:(BOOL)forceChild {
  if ([parent isKindOfClass:UINavigationController.class]) {
    UINavigationController *navigationController = (UINavigationController *) parent;
    return forceChild ? navigationController.topViewController : navigationController.visibleViewController;
  } else if ([parent isKindOfClass:UITabBarController.class]) {
    return ((UITabBarController *) parent).selectedViewController;
  } else if ([parent isKindOfClass:UIPageViewController.class]) {
    return ((UIPageViewController *) parent).viewControllers.firstObject;
  } else {
    return nil;
  }
}

+ (id <GDDPresenter>)findOrCreatePresenterForViewController:(UIViewController *)controller {
  if (![controller conformsToProtocol:@protocol(GDDView)]) {
    return nil;
  }
  if ([controller respondsToSelector:@selector(presenter)]) {
    return [(UIViewController <GDDView> *) controller presenter];
  }
  id <GDDPresenter> presenter = objc_getAssociatedObject(controller, &kPresenterKey);
  if (presenter) {
    return presenter;
  }
  // 使用命名约定: XyzViewController -> XyzPresenter
  Class presenterClass;
  NSString *viewControllerClassName = NSStringFromClass(controller.class);
  NSString *presenterClassName;
  NSString *const renderSuffix = @"ViewController";
  if ([viewControllerClassName hasSuffix:renderSuffix]) {
    presenterClassName = [viewControllerClassName substringToIndex:viewControllerClassName.length - renderSuffix.length];
    presenterClass = NSClassFromString([NSString stringWithFormat:@"%@Presenter", presenterClassName]);
  }
  if (!presenterClass) {
    [NSException raise:NSInvalidArgumentException format:@"Could not find a presenter class named '%@' for %@", presenterClassName, viewControllerClassName];
  }
  if ([presenterClass instancesRespondToSelector:@selector(initWithOwner:)]) {
    presenter = [(id <GDDPresenter>) [presenterClass alloc] initWithOwner:controller];
  } else {
    presenter = [[presenterClass alloc] init];
  }
  objc_setAssociatedObject(controller, &kPresenterKey, presenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return presenter;
}

@end
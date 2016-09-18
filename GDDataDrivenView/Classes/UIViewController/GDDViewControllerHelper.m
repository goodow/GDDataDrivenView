//
// Created by Larry Tin on 15/4/30.
//

#import "GDDViewControllerHelper.h"
#import <objc/runtime.h>
#import "Aspects.h"
#import "GDDPresenter.h"
#import "GDDView.h"

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kPresenterKey = 0;

@implementation GDDViewControllerHelper

+ (UIViewController *)topViewController {
  return [self findTopViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
}

+ (UIViewController *)backViewController {
  UIViewController *top = GDDViewControllerHelper.topViewController;
  NSArray *navViewControllers = top.navigationController.viewControllers;
  if (navViewControllers.count > 1) {
    return navViewControllers[navViewControllers.count - 2];
  } else if (top.presentingViewController) {
    UIViewController *child = [self getVisibleOrChildViewController:top.presentingViewController forceChild:YES];
    return child ?: top.presentingViewController;
  }
  return nil;
}

+ (void)show:(UIViewController *)controller message:(id <GDCMessage>)message {
  if (!controller) {
    return;
  }
  void (^messageHandler)() = ^{
      id <GDDPresenter> presenter = [self findOrCreatePresenterForViewController:controller];
      if (presenter) {
        NSParameterAssert([controller conformsToProtocol:@protocol(GDDView)]);
        [presenter update:(id <GDDView>) controller withData:message.payload];
      } else {
        [controller handleMessage:message];
      }
  };
  GDDPBExtrasOption *extras = message.options.extras;
  GDDPBViewOption *viewOpt = extras.hasViewOpt ? extras.viewOpt : nil;
  if (viewOpt.launchMode == GDDPBLaunchMode_None) {
    messageHandler();
    return;
  }

  UIViewController *found = [self find:controller in:UIApplication.sharedApplication.keyWindow.rootViewController instanceOrClass:YES];
  if (found) {
    [self config:controller viewOptions:viewOpt];
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
        if (viewOpt.stackMode == GDDPBStackMode_ReplaceRoot) {
          [GDDViewControllerHelper replaceRootViewController:controller];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            messageHandler();
        });
    };
    if (controller.presentedViewController) {
      [controller dismissViewControllerAnimated:YES completion:bringFoundToFront];
    } else {
      bringFoundToFront();
    }
    return;
  }

  BOOL forcePresent = NO, forcePresentWithoutNav = NO;
  /* config new controller */
  if (viewOpt) {
    controller.edgesForExtendedLayout = viewOpt.edgesForExtendedLayout;
    controller.hidesBottomBarWhenPushed = viewOpt.hidesBottomBarWhenPushed;
    switch (viewOpt.stackMode) {
      case GDDPBStackMode_Push:
        break;
      case GDDPBStackMode_PresentPush:
        forcePresent = YES;
        break;
      case GDDPBStackMode_Present:
        forcePresentWithoutNav = forcePresent = YES;
        break;
      case GDDPBStackMode_ReplaceRoot:
        if (![controller isKindOfClass:UITabBarController.class]) {
          controller = [[UINavigationController alloc] initWithRootViewController:controller];
        }
        [GDDViewControllerHelper replaceRootViewController:controller];
        [self config:controller viewOptions:viewOpt];
        if (!controller.isViewLoaded) {
          [controller view]; // force viewDidLoad to be called
        }
        messageHandler();
        return;
      default: {
        // Do nothing. Just make the compiler happy.
        break;
      }
    }

    if (forcePresent) {
      // 动画: 仅在 present 时有效
//      if (viewOptions.transition) {
//        controller.transitioningDelegate = viewOptions.transition;
//        controller.modalPresentationStyle = UIModalPresentationCustom;
//      }
      controller.modalTransitionStyle = viewOpt.modalTransitionStyle;
      controller.modalPresentationStyle = viewOpt.modalPresentationStyle;
    }
  }

  UIViewController *top = self.topViewController;
  if (!forcePresent && top.navigationController) {
    [top.navigationController pushViewController:controller animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self config:controller viewOptions:viewOpt];
        if (!controller.isViewLoaded) {
          [controller view]; // force viewDidLoad to be called
        }
        messageHandler();
    });
    return;
  }

  [top presentViewController:forcePresentWithoutNav ? controller : [[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
      [self config:controller viewOptions:viewOpt];
      messageHandler();
  }];
}

+ (void)replaceRootViewController:(UIViewController *)controller {
  UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
  if (rootViewController.presentedViewController) {
    [rootViewController dismissViewControllerAnimated:YES completion:^{
        UIApplication.sharedApplication.keyWindow.rootViewController = controller;
    }];
  } else {
    UIApplication.sharedApplication.keyWindow.rootViewController = controller;
  }
}

+ (UIViewController *)findViewController:(Class)viewControllerClass {
  return [self find:(id) viewControllerClass in:UIApplication.sharedApplication.keyWindow.rootViewController instanceOrClass:NO];
}

+ (UIViewController *)findTopViewController:(UIViewController *)parent {
  if (parent.presentedViewController) {
    return [self findTopViewController:parent.presentedViewController];
  }
  UIViewController *child = [self getVisibleOrChildViewController:parent forceChild:NO];
  return child ? [self findTopViewController:child] : parent;
}

+ (void)config:(UIViewController *)controller viewOptions:(GDDPBViewOption *)viewOpt {
  GDDPBViewOption *viewOption = controller.viewOption;
  if (viewOpt) {
    [viewOption mergeFrom:viewOpt];
  }

  enum GDPBBool statusBar = viewOption.statusBar;
  if (statusBar != GDPBBool_Default && GDPBBool_IsValidValue(statusBar)) {
    [controller setNeedsStatusBarAppearanceUpdate];
  }
  enum GDPBBool navBar = viewOption.navBar;
  if (navBar != GDPBBool_Default && GDPBBool_IsValidValue(navBar)) {
    [controller.navigationController setNavigationBarHidden:navBar == GDPBBool_False animated:NO];
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
//  if (options[optionStatusBarOrientation]) {
//    [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation) [options[optionStatusBarOrientation] integerValue]];
//  }
  if (viewOption.deviceOrientation) {
    viewOption.deviceOrientation = UIDeviceOrientationUnknown;
    [[UIDevice currentDevice] setValue:@(viewOption.deviceOrientation) forKey:@"orientation"];
  }
  if (viewOption.attemptRotationToDeviceOrientation) {
    viewOption.attemptRotationToDeviceOrientation = NO;
    [UIViewController attemptRotationToDeviceOrientation];
  }
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

+ (void)aspect_hookSelector {
  [UIViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerHelper getVisibleOrChildViewController:instance forceChild:YES];
      BOOL toRtn;
      if (child) {
        toRtn = [child shouldAutorotate];
      } else {
        enum GDPBBool autorotate = instance.viewOption.autorotate;
        if (autorotate != GDPBBool_Default && GDPBBool_IsValidValue(autorotate)) {
          toRtn = autorotate == GDPBBool_True;
        } else {
          [invocation invoke];
          [invocation getReturnValue:&toRtn];
        }
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
  [UIViewController aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerHelper getVisibleOrChildViewController:instance forceChild:YES];
      UIInterfaceOrientationMask toRtn;
      if (child) {
        toRtn = [child supportedInterfaceOrientations];
      } else {
        UIInterfaceOrientationMask supportedInterfaceOrientations = instance.viewOption.supportedInterfaceOrientations;
        if (supportedInterfaceOrientations) {
          toRtn = supportedInterfaceOrientations;
        } else {
          [invocation invoke];
          [invocation getReturnValue:&toRtn];
        }
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
  [UIViewController aspect_hookSelector:@selector(preferredInterfaceOrientationForPresentation) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerHelper getVisibleOrChildViewController:instance forceChild:YES];
      UIInterfaceOrientation toRtn;
      if (child) {
        toRtn = [child preferredInterfaceOrientationForPresentation];
      } else {
        UIInterfaceOrientation preferredInterfaceOrientationForPresentation = instance.viewOption.preferredInterfaceOrientationForPresentation;
        if (preferredInterfaceOrientationForPresentation) {
          toRtn = preferredInterfaceOrientationForPresentation;
        } else {
          [invocation invoke];
          [invocation getReturnValue:&toRtn];
        }
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];

  [UIViewController aspect_hookSelector:@selector(prefersStatusBarHidden) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      BOOL toRtn;
      enum GDPBBool statusBar = instance.viewOption.statusBar;
      if (statusBar != GDPBBool_Default && GDPBBool_IsValidValue(statusBar)) {
        toRtn = statusBar == GDPBBool_False;
      } else {
        [invocation invoke];
        [invocation getReturnValue:&toRtn];
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
  [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIStatusBarStyle toRtn = instance.viewOption.statusBarStyle;
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
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
  id <GDDPresenter> presenter = objc_getAssociatedObject(self, &kPresenterKey);
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

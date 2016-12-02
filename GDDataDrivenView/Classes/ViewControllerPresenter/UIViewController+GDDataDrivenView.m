#import "UIViewController+GDDataDrivenView.h"
#import <objc/runtime.h>
#import "Aspects.h"

@protocol GDDRender;

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kViewOptionKey = 0;
static const char kPresenterKey = 0;

@implementation UIViewController (GDDataDrivenView)

- (GDDPBViewOption *)viewOption {
  GDDPBViewOption *viewOption = objc_getAssociatedObject(self, &kViewOptionKey);
  if (!viewOption) {
    viewOption = [GDDPBViewOption message];
    objc_setAssociatedObject(self, &kViewOptionKey, viewOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return viewOption;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
  if ([self conformsToProtocol:@protocol(GDDView)] && sel == @selector(presenter)) {
    return [self addPresenterMethodToView:self.class];
  }

  return [super resolveInstanceMethod:sel];
}

+ (BOOL)addPresenterMethodToView:(Class)aClass {
  IMP impToAdd = imp_implementationWithBlock(^(id viewOrController) {
      id <GDDPresenter> presenter = objc_getAssociatedObject(viewOrController, &kPresenterKey);
      if (presenter) {
        return presenter;
      }
      // 使用命名约定: XyzViewController/XyzView -> XyzPresenter
      Class presenterClass;
      NSString *viewClassName = NSStringFromClass([viewOrController class]);
      NSString *presenterClassName;
      NSString *const renderSuffix = [viewOrController isKindOfClass:UIViewController.class] ? @"ViewController" : @"View";
      if ([viewClassName hasSuffix:renderSuffix]) {
        presenterClassName = [viewClassName substringToIndex:viewClassName.length - renderSuffix.length];
        presenterClassName = [NSString stringWithFormat:@"%@Presenter", presenterClassName];
        presenterClass = NSClassFromString(presenterClassName);
      }
      if (!presenterClass) {
        [NSException raise:NSInvalidArgumentException format:@"Could not find a presenter class named '%@' for %@", presenterClassName, viewClassName];
      }
      if ([presenterClass instancesRespondToSelector:@selector(initWithOwner:)]) {
        presenter = [(id <GDDPresenter>) [presenterClass alloc] initWithOwner:viewOrController];
      } else {
        presenter = [[presenterClass alloc] init];
      }
      objc_setAssociatedObject(viewOrController, &kPresenterKey, presenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      return presenter;
  });

  Protocol *protocol = @protocol(GDDView);
  SEL sel = @selector(presenter);
  struct objc_method_description description = protocol_getMethodDescription(protocol, sel, NO, YES);
  BOOL methodAdded = class_addMethod(aClass, sel, impToAdd, description.types);
  return methodAdded;
}

@end


@implementation UIView (GDDataDrivenView)

+ (BOOL)resolveInstanceMethod:(SEL)sel {
  if ([self conformsToProtocol:@protocol(GDDView)] && ![self conformsToProtocol:@protocol(GDDRender)] && sel == @selector(presenter)) {
    return [UIViewController addPresenterMethodToView:self.class];
  }

  return [super resolveInstanceMethod:sel];
}

@end


@implementation GDDViewControllerTransition (GDDataDrivenView)

+ (void)aspect_hookSelector {
  [UIViewController aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerTransition getVisibleOrChildViewController:instance forceChild:YES];
      BOOL toRtn;
      if (child) {
        toRtn = [child shouldAutorotate];
      } else {
        enum GDPBBool autorotate = instance.viewOption.autorotate;
        if (autorotate != GDPBBool_Default && GDPBBool_IsValidValue(autorotate)) {
          toRtn = autorotate == GDPBBool_True;
        } else {
          [invocation invoke];
          return;
        }
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
  [UIViewController aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerTransition getVisibleOrChildViewController:instance forceChild:YES];
      UIInterfaceOrientationMask toRtn;
      if (child) {
        toRtn = [child supportedInterfaceOrientations];
      } else {
        UIInterfaceOrientationMask supportedInterfaceOrientations = instance.viewOption.supportedInterfaceOrientations;
        if (supportedInterfaceOrientations) {
          toRtn = supportedInterfaceOrientations;
        } else {
          [invocation invoke];
          return;
        }
      }
      [invocation setReturnValue:&toRtn];
  }                               error:nil];
  [UIViewController aspect_hookSelector:@selector(preferredInterfaceOrientationForPresentation) withOptions:AspectPositionInstead usingBlock:^(id <AspectInfo> info) {
      NSInvocation *invocation = info.originalInvocation;
      UIViewController *instance = info.instance;
      UIViewController *child = [GDDViewControllerTransition getVisibleOrChildViewController:instance forceChild:YES];
      UIInterfaceOrientation toRtn;
      if (child) {
        toRtn = [child preferredInterfaceOrientationForPresentation];
      } else {
        UIInterfaceOrientation preferredInterfaceOrientationForPresentation = instance.viewOption.preferredInterfaceOrientationForPresentation;
        if (preferredInterfaceOrientationForPresentation) {
          toRtn = preferredInterfaceOrientationForPresentation;
        } else {
          [invocation invoke];
          return;
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
        return;
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

@end
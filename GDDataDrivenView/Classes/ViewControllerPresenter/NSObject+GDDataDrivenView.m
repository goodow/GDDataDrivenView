//
// Created by Larry Tin on 16/9/12.
//

#import "NSObject+GDDataDrivenView.h"
#import "Aspects.h"

@implementation NSObject (GDDataDrivenView)

- (void)subscribeLocalToSelf:(NSArray<NSString *> *)topics {
  NSMutableArray *consumers = [NSMutableArray arrayWithCapacity:topics.count];
  for (NSString *topic in topics) {
    [consumers addObject:[self subscribe:self toOne:topic]];
  }
  [self aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
      for (id <GDCMessageConsumer> consumer in consumers) {
        [consumer unsubscribe];
      }
      [consumers removeAllObjects];
  } error:NULL];
}

- (id <GDCMessageConsumer>)subscribe:(NSObject <GDCMessageHandler> *)handler toOne:(NSString *)topic {
  __weak id <GDCMessageHandler> weakHandler = handler;
  return [self.bus subscribeLocal:topic handler:^(id <GDCMessage> message) {
      [weakHandler handleMessage:message];
  }];
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
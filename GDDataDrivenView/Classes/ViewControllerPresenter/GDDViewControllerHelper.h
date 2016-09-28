//
// Created by Larry Tin on 15/4/30.
//

#import <UIKit/UIKit.h>
#import "GDCMessage.h"
#import "NSObject+GDChannel.h"
#import "GoodowBool.pbobjc.h"
#import "GoodowExtrasOption.pbobjc.h"
#import "UIViewController+GDDataDrivenView.h"
#import "GDDPresenter.h"

NS_ASSUME_NONNULL_BEGIN
@interface GDDViewControllerHelper : NSObject

+ (UIViewController *)topViewController;

+ (void)show:(UIViewController *)controller message:(id <GDCMessage>)message;

+ (UIViewController *)findViewController:(Class)viewControllerClass;

+ (void)aspect_hookSelector;

+ (void)up:(id <GDCMessage>)message;
+ (void)option:(id <GDCMessage>)message;
+ (void)load:(id <GDCMessage>)message withClass:(Class)clz;

@end
NS_ASSUME_NONNULL_END

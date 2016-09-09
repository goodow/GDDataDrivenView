//
// Created by Larry Tin on 15/4/30.
//

#import <UIKit/UIKit.h>
#import "GDCMessage.h"
#import "NSObject+GDChannel.h"
#import "GoodowBool.pbobjc.h"
#import "GoodowExtrasOption.pbobjc.h"
#import "UIViewController+GDDataDrivenView.h"

NS_ASSUME_NONNULL_BEGIN
@interface GDDViewControllerHelper : NSObject

+ (UIViewController *)topViewController;

+ (UIViewController *)backViewController;

+ (void)show:(UIViewController *)controller message:(id <GDCMessage>)message;

+ (void)config:(UIViewController *)controller viewOptions:(GDDPBViewOption *)viewOption;

+ (UIViewController *)findViewController:(Class)viewControllerClass;

+ (void)aspect_hookSelector;
@end
NS_ASSUME_NONNULL_END

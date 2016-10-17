//
// Created by Larry Tin on 16/9/12.
//

#import <Foundation/Foundation.h>
#import "NSObject+GDChannel.h"
#import "GDDViewControllerTransition.h"

@interface NSObject (GDDataDrivenView)

- (void)subscribeLocalToSelf:(NSArray<NSString *> *)topics;

@end

@interface GDDViewControllerTransition (GDDataDrivenView)

+ (void)aspect_hookSelector;

+ (UIViewController *)getVisibleOrChildViewController:(UIViewController *)parent forceChild:(BOOL)forceChild;

@end
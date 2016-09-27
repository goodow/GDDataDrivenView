//
// Created by Larry Tin on 16/9/12.
//

#import <Foundation/Foundation.h>
#import "NSObject+GDChannel.h"

@interface NSObject (GDDataDrivenView)

- (void)subscribeLocalToSelf:(NSArray<NSString *> *)topics;

@end
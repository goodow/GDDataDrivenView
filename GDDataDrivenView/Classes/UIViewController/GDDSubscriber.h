//
// Created by Larry Tin on 16/9/12.
//

#import <Foundation/Foundation.h>

@protocol GDCMessageHandler;


@interface GDDSubscriber : NSObject

- (void)subscribe:(NSString *)topic, ... to:(id<GDCMessageHandler>)handler;

@end
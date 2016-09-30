//
// Created by Larry Tin on 16/9/30.
//

#import <Foundation/Foundation.h>

@protocol GDDRpc

- (id <GDDRpc> (^)(void (^)(id response)))success;

- (id <GDDRpc> (^)(void (^)(NSError *)))failure;

- (void)load;

@optional
- (void (^)(id cursor))loadMore;

@end
#import <Foundation/Foundation.h>

@protocol GDDRpc

- (id <GDDRpc> (^)(void (^)(id result)))success;

- (id <GDDRpc> (^)(void (^)(NSError *)))failure;

- (void)load;

@optional
- (void (^)(id cursor))loadMore;

@end
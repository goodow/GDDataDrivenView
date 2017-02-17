#import <Foundation/Foundation.h>

@protocol GDDTask
-(void)cancel;
@end

@protocol GDDRpc

- (id <GDDRpc> (^)(void (^)(id result)))success;

- (id <GDDRpc> (^)(void (^)(NSError *)))failure;

- (nullable id<GDDTask> (^)(id query))load;

@end
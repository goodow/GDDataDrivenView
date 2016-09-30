#import <Foundation/Foundation.h>
#import "GDDRpc.h"

@protocol GDDListService

- (id<GDDRpc>)listRequest:(nullable id)param;

@end
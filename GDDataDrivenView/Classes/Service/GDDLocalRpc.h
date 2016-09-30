#import "GDDRpc.h"

@interface GDDLocalRpc<__covariant ObjectType> : NSObject <GDDRpc>

- (GDDLocalRpc<ObjectType> *(^)(ObjectType result))result;
- (GDDLocalRpc<ObjectType> *(^)(NSError *error))error;

@end
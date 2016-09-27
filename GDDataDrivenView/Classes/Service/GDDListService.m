#import "GDDListService.h"

@implementation GDDListService {

}

- (void)listWithParam:(id)param cursor:(id)cursor success:(void (^)(id))success failure:(void (^)(NSError *))failure {
  [NSException raise:@"Invoked abstract method" format:@"%s", __PRETTY_FUNCTION__];
}

- (void)listWithParam:(id)param success:(void (^)(id))success failure:(void (^)(NSError *))failure {
  [self listWithParam:param cursor:nil success:success failure:failure];
}

@end
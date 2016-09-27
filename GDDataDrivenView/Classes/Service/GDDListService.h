#import <Foundation/Foundation.h>
#import "GDDListModel.h"
@class GPBMessage;

@interface GDDListService<__covariant ParameterType, __covariant ResultType : GDDListModel *> : NSObject

- (void)listWithParam:(nullable id)param
              success:(void (^)(ResultType model))success
              failure:(nullable void (^)(NSError *))failure;

- (void)listWithParam:(nullable ParameterType)param
               cursor:(nullable id)cursor
              success:(nullable void (^)(ResultType model))success
              failure:(nullable void (^)(NSError *_Nullable))failure;

@end
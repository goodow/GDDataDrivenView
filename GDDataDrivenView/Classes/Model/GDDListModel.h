#import "GDDModel.h"

@class GPBMessage;

@interface GDDListModel<__covariant ObjectType> : GDDModel

@property(nonatomic, readonly) NSArray<ObjectType> *results;
@property(nonatomic, readonly) NSString *nextCursor;

- (instancetype)initWithResults:(NSArray *)results response:(GPBMessage *)response;

@end
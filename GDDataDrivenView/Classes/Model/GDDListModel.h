#import "GDDModel.h"

@interface GDDListModel<__covariant ObjectType> : GDDModel

@property(nonatomic) NSArray<ObjectType> *results;
@property(nonatomic) id nextCursor;

- (instancetype)initWithResults:(NSArray<ObjectType> *)results;

@end
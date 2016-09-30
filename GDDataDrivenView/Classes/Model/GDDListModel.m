#import "GDDListModel.h"

@interface GDDListModel ()
@end

@implementation GDDListModel

- (instancetype)initWithResults:(NSArray *)results {
  self = [super init];
  if (self) {
    _results = results;
  }

  return self;
}
@end
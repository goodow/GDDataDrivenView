#import "GDDListModel.h"
#import "GPBMessage.h"

@interface GDDListModel ()
@property(nonatomic, readonly) GPBMessage *response;
@end

@implementation GDDListModel

- (instancetype)initWithResults:(NSArray *)results response:(GPBMessage *)response {
  self = [super init];
  if (self) {
    _results = results;
    _response = response;
  }

  return self;
}


- (NSString *)nextCursor {
  if ([self.response respondsToSelector:@selector(hasNextPage)] && ![[self.response valueForKey:@"hasNextPage"] boolValue]) {
    return nil;
  }
  return [self.response respondsToSelector:@selector(pageContext)] ? [self.response valueForKey:@"pageContext"] : nil;
}

@end
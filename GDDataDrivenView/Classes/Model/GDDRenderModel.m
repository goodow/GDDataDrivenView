//
// Created by Larry Tin on 7/9/16.
//

#import "GDDRenderModel.h"


@implementation GDDRenderModel {

}

- (instancetype)initWithData:(id)data withId:(NSString *)mid withRenderClass:(Class)renderClass {
  self = [super init];
  if (self) {
    _data = data;
    _mid = mid;
    _renderClass = renderClass;
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  GDDRenderModel *copy = [[GDDRenderModel allocWithZone:zone] initWithData:self.data withId:self.mid withRenderClass:self.renderClass];
  copy.tapHandler = self.tapHandler;
  return copy;
}

#pragma mark Event Handler
- (void)handleTap:(UITapGestureRecognizer *)sender {
  if (self.tapHandler) {
    self.tapHandler(self, sender);
  }
}

@end
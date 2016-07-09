//
// Created by Larry Tin on 7/9/16.
//

#import "GDDRenderModel.h"


@implementation GDDRenderModel {

}

#pragma mark Event Handler
- (void)handleTap:(UITapGestureRecognizer *)sender {
  if (self.tapHandler) {
    self.tapHandler(self, sender);
  }
}
@end
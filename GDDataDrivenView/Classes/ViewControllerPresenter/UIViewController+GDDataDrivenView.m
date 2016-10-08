#import <objc/runtime.h>
#import "UIViewController+GDDataDrivenView.h"
#import "GoodowExtrasOption.pbobjc.h"

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kViewOptionKey = 0;

@implementation UIViewController (GDDataDrivenView)

- (GDDPBViewOption *)viewOption {
  GDDPBViewOption *viewOption = objc_getAssociatedObject(self, &kViewOptionKey);
  if (!viewOption) {
    viewOption = [GDDPBViewOption message];
    objc_setAssociatedObject(self, &kViewOptionKey, viewOption, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return viewOption;
}

@end
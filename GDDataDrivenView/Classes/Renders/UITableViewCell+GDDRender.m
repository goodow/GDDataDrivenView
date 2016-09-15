//
// Created by Larry Tin on 16/9/12.
//

#import "UITableViewCell+GDDRender.h"


@implementation UITableViewCell (GDDRender)

- (UITableView *)nearestTableView {
  UIView *view = self.superview;
  do {
    view = view.superview;
  } while (view && ![view isKindOfClass:UITableView.class]);
  return view;
}

@end
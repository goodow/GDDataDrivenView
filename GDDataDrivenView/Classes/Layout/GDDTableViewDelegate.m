//
// Created by Larry Tin on 16/7/11.
//

#import "GDDTableViewDelegate.h"
#import "GDDModel.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import <objc/runtime.h>

@implementation GDDTableViewDelegate {
  __weak GDDTableViewDataSource *_dataSource;
}

- (instancetype)initWithDataSource:(GDDTableViewDataSource *)dataSource{
  self = [super init];
  if (self) {
    _dataSource = dataSource;
  }
  return self;
}

#pragma mark Cell Height calculating

#if !(SelfSizing_UpdateConstraints)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDModel *model = [_dataSource modelForIndexPath:indexPath];
  UITableViewCell *cell = [_dataSource renderForModel:model];
  if (!cell) {
    return 1;
  }
  return [self fd_systemFittingHeightForConfiguratedCell:cell tableView:tableView];
}
#endif

- (CGFloat)fd_systemFittingHeightForConfiguratedCell:(UITableViewCell *)cell tableView:(UITableView *)tableView {
  CGFloat contentViewWidth = CGRectGetWidth(tableView.frame);

  // If a cell has accessory view or system accessory type, its content view's width is smaller
  // than cell's by some fixed values.
  if (cell.accessoryView) {
    contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
  } else {
    static const CGFloat systemAccessoryWidths[] = {
        [UITableViewCellAccessoryNone] = 0,
        [UITableViewCellAccessoryDisclosureIndicator] = 34,
        [UITableViewCellAccessoryDetailDisclosureButton] = 68,
        [UITableViewCellAccessoryCheckmark] = 40,
        [UITableViewCellAccessoryDetailButton] = 48
    };
    contentViewWidth -= systemAccessoryWidths[cell.accessoryType];
  }

  // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
  // This is the same height calculation passes used in iOS8 self-sizing cell's implementation.
  //
  // 1. Try "- systemLayoutSizeFittingSize:" first. (skip this step if 'fd_enforceFrameLayout' set to YES.)
  // 2. Warning once if step 1 still returns 0 when using AutoLayout
  // 3. Try "- sizeThatFits:" if step 1 returns 0
  // 4. Use a valid height or default row height (44) if not exist one

  CGFloat fittingHeight = 0;

//  if (!cell.fd_enforceFrameLayout && contentViewWidth > 0) {
  if (contentViewWidth > 0) {
    // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
    // of growing horizontally, in a flow-layout manner.
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
    [cell.contentView addConstraint:widthFenceConstraint];

    // Auto layout engine does its math
    fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [cell.contentView removeConstraint:widthFenceConstraint];

//    [self fd_debugLog:[NSString stringWithFormat:@"calculate using system fitting size (AutoLayout) - %@", @(fittingHeight)]];
  }

  if (fittingHeight == 0) {
#if DEBUG
    // Warn if using AutoLayout but get zero height.
    if (cell.contentView.constraints.count > 0) {
      if (!objc_getAssociatedObject(self, _cmd)) {
        NSLog(@"[FDTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
        objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      }
    }
#endif
    // Try '- sizeThatFits:' for frame layout.
    // Note: fitting height should not include separator view.
    fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;

//    [self fd_debugLog:[NSString stringWithFormat:@"calculate using sizeThatFits - %@", @(fittingHeight)]];
  }

  // Still zero height after all above.
  if (fittingHeight == 0) {
    // Use default row height.
    fittingHeight = 44;
  }

  // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
  if (tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
    fittingHeight += 1.0 / [UIScreen mainScreen].scale;
  }

  return fittingHeight;
}
@end
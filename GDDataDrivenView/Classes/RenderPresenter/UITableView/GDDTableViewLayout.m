//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewLayout.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import "GDDTableViewDelegate.h"

@interface GDDTableViewLayout ()
@property(nonatomic) GDDTableViewDelegate *delegate;

@end

@implementation GDDTableViewLayout {
}
- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)layoutTopic withOwner:(id)owner {
  self = [super initWithTopic:layoutTopic withView:tableView];
  if (self) {
    super.dataSource = [[GDDTableViewDataSource alloc] initWithTableView:tableView withLayout:self withOwner:owner];
    tableView.dataSource = super.dataSource;

#if SelfSizing_UpdateConstraints
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    tableView.estimatedRowHeight = 213; // set this to whatever your "average" cell height is; it doesn't need to be very accurate
    // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
    tableView.rowHeight = UITableViewAutomaticDimension;
#else
    // 配置tableView代理
    _delegate = [[GDDTableViewDelegate alloc] initWithDataSource:super.dataSource withOriginalDelegate:tableView.delegate];
    tableView.delegate = _delegate;
#endif

    // 配置tableView样式
    tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  }

  return self;
}

@end
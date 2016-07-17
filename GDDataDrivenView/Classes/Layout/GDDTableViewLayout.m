//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewLayout.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import "GDDTableViewDelegate.h"
#import "SVPullToRefresh.h"

static NSString *const modelsPath = @"models";
static NSString *const sectionsPath = @"sections";

@interface GDDTableViewLayout () <UITableViewDelegate>
@property(nonatomic) GDDTableViewDataSource *dataSource;
@property(nonatomic) GDDTableViewDelegate *delegate;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic) NSString *modelsTopic;
@property(nonatomic) NSString *sectionsTopic;
@property(nonatomic) NSMutableArray<GDDModel *> *models;
@end

@implementation GDDTableViewLayout {
  id <GDCMessageConsumer> _consumer;
  NSString *_layoutTopic;
}
- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)layoutTopic {
  self = [super init];
  if (self) {
    _tableView = tableView;
    _modelsTopic = [[layoutTopic stringByAppendingPathComponent:modelsPath] stringByAppendingString:@"/"];
    _sectionsTopic = [[layoutTopic stringByAppendingPathComponent:sectionsPath] stringByAppendingString:@"/"];
    _dataSource = [[GDDTableViewDataSource alloc] initWithTableView:tableView withLayout:self];
    _delegate = [[GDDTableViewDelegate alloc] initWithDataSource:_dataSource];

    // 配置tableView代理
    tableView.dataSource = _dataSource;
    tableView.delegate = _delegate;

    // 自动算高, 配合systemLayoutSizeFittingSize:使用
    tableView.estimatedRowHeight = 213;

    // 配置tableView样式
    tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // 设置topic
    [self setTopic:layoutTopic];
  }

  return self;
}

- (void)setTopic:(NSString *)layoutTopic {
  _layoutTopic = layoutTopic;
  __weak GDDTableViewLayout *weakSelf = self;
  NSString *wildcardTopic = [layoutTopic stringByAppendingPathComponent:@"#"];
  _consumer = [self.bus subscribeLocal:wildcardTopic handler:^(id <GDCMessage> message) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSString *topic = message.topic;
          if ([topic hasPrefix:weakSelf.sectionsTopic]) {
            NSInteger section = [topic substringFromIndex:weakSelf.sectionsTopic.length].integerValue;
            [weakSelf reloadModels:message.payload forSection:section];
            return;
          }
          if ([topic hasPrefix:weakSelf.modelsTopic]) {
            NSString *mid = [topic substringFromIndex:weakSelf.modelsTopic.length];
            [self mergeModel:message.payload forId:mid];
            return;
          }
      });
  }];
}

- (NSString *)topicForSection:(NSInteger)section {
  return [self.sectionsTopic stringByAppendingPathComponent:@(section).stringValue];
}

- (void)dealloc {
  [_consumer unsubscribe];
  _consumer = nil;
}

#pragma mark Change model

- (void)reloadModels:(NSArray<GDDModel *> *)models forSection:(NSInteger)section {
  self.models = models;
  NSArray<GDDModel *> *patches = [self diffMatch];
  if (patches) {
    [self appendNewModels:patches];
    return;
  }
  [self.dataSource clearModels];
  NSMutableArray *indexPaths = [self generateNewIndexPaths:models.count];
  [self.dataSource insertModels:models atIndexPaths:indexPaths];
  __weak UITableView *tableView = self.tableView;
  dispatch_async(dispatch_get_main_queue(), ^{
//      [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
      [tableView reloadData];
  });
}

- (NSArray<GDDModel *> *)diffMatch { //  oldRowCount:(int *)oldRowCount {
  NSInteger lastSection = [self.dataSource numberOfSectionsInTableView:self.tableView] - 1;
  NSInteger rowsInLastSection = [self.dataSource tableView:self.tableView numberOfRowsInSection:lastSection];
//  if (oldRowCount) {
//    *oldRowCount = rowsInLastSection;
//  }
  if (rowsInLastSection == 0 || self.models.count < rowsInLastSection) {
    return nil;
  }
  for (int row = rowsInLastSection - 1; row >= 0; row--) {
    GDDModel *model = [self.dataSource modelForIndexPath:[NSIndexPath indexPathForRow:row inSection:lastSection]];
    if (![model isEqual:self.models[row]]) {
      return nil;
    }
  }
  return [self.models subarrayWithRange:NSMakeRange(rowsInLastSection, self.models.count - rowsInLastSection)];
}

- (void)appendNewModels:(NSArray<GDDModel *> *)newModels {
  if (newModels.count == 0) {
    return;
  }
  NSMutableArray *indexPaths = [self generateNewIndexPaths:newModels.count];
  [self.dataSource insertModels:newModels atIndexPaths:indexPaths];
  __weak UITableView *tableView = self.tableView;
//  NSArray<NSIndexPath *> *visibleRows = [tableView indexPathsForVisibleRows];
//  NSComparisonResult result1 = [indexPaths.firstObject compare:visibleRows.firstObject];
//  if (result1 == NSOrderedSame || result1 == NSOrderedDescending) {
//    NSComparisonResult result2 = [indexPaths.firstObject compare:visibleRows.lastObject];
//    if (result2 == NSOrderedSame || result2 == NSOrderedAscending) {
//      // cell is visible, reload immediately
  dispatch_async(dispatch_get_main_queue(), ^{
      [UIView setAnimationsEnabled:NO];
      [tableView beginUpdates];
      [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
      [tableView endUpdates];
      if (tableView.infiniteScrollingView.state == SVInfiniteScrollingStateLoading) {
        [tableView.infiniteScrollingView stopAnimating];
      }
      [UIView setAnimationsEnabled:YES];
  });
//    }
//  }
}

- (NSMutableArray *)generateNewIndexPaths:(int)count {
  NSMutableArray *indexPaths = @[].mutableCopy;
  NSInteger lastSection = MAX([self.dataSource numberOfSectionsInTableView:self.tableView] - 1, 0);
  int lastRow = [self.dataSource tableView:self.tableView numberOfRowsInSection:lastSection] - 1;
  for (int i = 0; i < count; i++) {
    [indexPaths addObject:[NSIndexPath indexPathForRow:++lastRow inSection:lastSection]];
  }
  return indexPaths;
}

- (void)mergeModel:(GDDModel *)patch forId:(NSString *)mid {
  NSIndexPath *indexPath = [self.dataSource indexPathForId:mid];
  GDDModel *model = [self.dataSource modelForIndexPath:indexPath];
  [model mergeFrom:patch];
  __weak GDDTableViewLayout *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
      [model reloadData];
      [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  });
}

#pragma mark Event Handler

- (void)setInfiniteScrollingHandler:(id)infiniteScrollingHandler {
  if (!infiniteScrollingHandler) {
    _infiniteScrollingHandler = nil;
    self.tableView.showsInfiniteScrolling = NO;
    return;
  }
  _infiniteScrollingHandler = [infiniteScrollingHandler copy];
  __weak GDDTableViewLayout *weakSelf = self;
  [self.tableView addInfiniteScrollingWithActionHandler:^{
      if (weakSelf.infiniteScrollingHandler) {
        weakSelf.infiniteScrollingHandler(weakSelf.models.copy, ^(BOOL hasMore) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            if (!hasMore) {
              self.tableView.showsInfiniteScrolling = NO;
            }
        });
      }
  }];
}

@end
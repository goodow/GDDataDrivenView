//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewLayout.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import "GDDModel.h"
#import "GDDTableViewDelegate.h"

static NSString *const modelsPath = @"models";

@interface GDDTableViewLayout () <UITableViewDelegate>
@property(nonatomic) GDDTableViewDataSource *dataSource;
@property(nonatomic) GDDTableViewDelegate *delegate;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic) NSString *modelsTopic;
@end

@implementation GDDTableViewLayout {
  id <GDCMessageConsumer> _consumer;
  NSMutableArray<GDDModel *> *_models;
}
- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)layoutTopic {
  self = [super init];
  if (self) {
    _tableView = tableView;
    _modelsTopic = [[layoutTopic stringByAppendingPathComponent:modelsPath] stringByAppendingString:@"/"];
    _dataSource = [[GDDTableViewDataSource alloc] initWithTableView:tableView];
    _delegate = [[GDDTableViewDelegate alloc] init];
    _delegate.dataSource = _dataSource;
    tableView.dataSource = _dataSource;
    tableView.delegate = _delegate;

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
          if ([message.topic isEqualToString:weakSelf.layoutTopic]) {
            [weakSelf reloadModels:message.payload];
            return;
          }
          if ([message.topic hasPrefix:weakSelf.modelsTopic]) {
            NSString *mid = [message.topic substringFromIndex:weakSelf.modelsTopic.length];
            [self mergeModel:message.payload forId:mid];
            return;
          }
      });
  }];
}

- (void)dealloc {
  [_consumer unsubscribe];
  _consumer = nil;
}

#pragma mark Change model

- (void)reloadModels:(NSArray<GDDModel *> *)models {
  _models = models;
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
      [tableView reloadData];
  });
}

- (NSArray<GDDModel *> *)diffMatch { //  oldRowCount:(int *)oldRowCount {
  NSInteger lastSection = [self.dataSource numberOfSectionsInTableView:self.tableView] - 1;
  NSInteger rowsInLastSection = [self.dataSource tableView:self.tableView numberOfRowsInSection:lastSection];
//  if (oldRowCount) {
//    *oldRowCount = rowsInLastSection;
//  }
  if (rowsInLastSection == 0 || _models.count < rowsInLastSection) {
    return nil;
  }
  for (int row = rowsInLastSection - 1; row >= 0; row--) {
    GDDModel *model = [self.dataSource modelForIndexPath:[NSIndexPath indexPathForRow:row inSection:lastSection]];
    if (![model isEqual:_models[row]]) {
      return nil;
    }
  }
  //  return [_models subarrayWithRange:NSMakeRange(rowsInLastSection, _models.count - rowsInLastSection)];
  NSMutableArray<GDDModel *> *newModels = @[].mutableCopy;
  for (int row = rowsInLastSection; row < _models.count; row++) {
    GDDModel *model = _models[row];
    if ([_models containsObject:model]) {
      model = model.copy;
      [_models replaceObjectAtIndex:row withObject:model];
    }
    [newModels addObject:model];
  }
  return newModels;
}

- (void)appendNewModels:(NSArray<GDDModel *> *)newModels {
  if (newModels.count == 0) {
    return;
  }
  NSMutableArray *indexPaths = [self generateNewIndexPaths:newModels.count];
  [self.dataSource insertModels:newModels atIndexPaths:indexPaths];
  __weak UITableView *tableView = self.tableView;
  dispatch_async(dispatch_get_main_queue(), ^{
      [tableView beginUpdates];
      [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
      [tableView endUpdates];
  });
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
  GDDModel *model = [self.dataSource modelForId:mid];
  [model mergeFrom:patch];
  dispatch_async(dispatch_get_main_queue(), ^{
      [model reloadData];
  });
}

@end
//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewLayout.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import "GDDRenderModel.h"
#import "GDDTableViewDelegate.h"

static NSString *const modelsPath = @"models";

@interface GDDTableViewLayout () <UITableViewDelegate>
@property(nonatomic) GDDTableViewDataSource *dataSource;
@property(nonatomic) GDDTableViewDelegate *delegate;
@property(nonatomic, weak) UITableView *tableView;
@end

@implementation GDDTableViewLayout {
  id <GDCMessageConsumer> _consumer;
  NSMutableArray<GDDRenderModel *> *_models;
}
- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)topic {
  self = [super init];
  if (self) {
    _tableView = tableView;
    _dataSource = [[GDDTableViewDataSource alloc] initWithTopic:topic];
    _delegate = [[GDDTableViewDelegate alloc] init];
    _delegate.dataSource = _dataSource;
    tableView.dataSource = _dataSource;
    tableView.delegate = _delegate;

    // 配置tableView样式
    tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // 设置topic
    [self setTopic:topic];
  }

  return self;
}

- (void)setTopic:(NSString *)topic {
  _topic = topic;
  __weak GDDTableViewLayout *weakSelf = self;
  NSString *wildcardTopic = [topic stringByAppendingPathComponent:@"#"];
  _consumer = [self.bus subscribeLocal:wildcardTopic handler:^(id <GDCMessage> message) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          if ([message.topic isEqualToString:weakSelf.topic]) {
            [weakSelf reloadRenderModels:message.payload];
            return;
          }
          NSString *modelsPrefix = [topic stringByAppendingPathComponent:modelsPath];
          if ([message.topic hasPrefix:modelsPrefix]) {
            [weakSelf updateRenderModel:message withModelId:[topic substringFromIndex:modelsPrefix.length]];
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

- (void)reloadRenderModels:(NSArray<GDDRenderModel *> *)models {
  _models = models;
  NSArray<GDDRenderModel *> *patches = [self diffMatch];
  if (patches) {
    [self appendNewRenderModels:patches];
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

- (NSArray<GDDRenderModel *> *)diffMatch { //  oldRowCount:(int *)oldRowCount {
  NSInteger lastSection = [self.dataSource numberOfSectionsInTableView:self.tableView] - 1;
  NSInteger rowsInLastSection = [self.dataSource tableView:self.tableView numberOfRowsInSection:lastSection];
//  if (oldRowCount) {
//    *oldRowCount = rowsInLastSection;
//  }
  if (rowsInLastSection == 0 || _models.count < rowsInLastSection) {
    return nil;
  }
  for (int row = rowsInLastSection - 1; row >= 0; row--) {
    GDDRenderModel *model = [self.dataSource renderModelForIndexPath:[NSIndexPath indexPathForRow:row inSection:lastSection]];
    if (![model isEqual:_models[row]]) {
      return nil;
    }
  }
  //  return [_models subarrayWithRange:NSMakeRange(rowsInLastSection, _models.count - rowsInLastSection)];
  NSMutableArray<GDDRenderModel *> * newModels = @[].mutableCopy;
  for (int row = rowsInLastSection; row < _models.count; row++) {
    GDDRenderModel *model = _models[row];
    if ([_models containsObject:model]) {
      model = model.copy;
      [_models replaceObjectAtIndex:row withObject:model];
    }
    [newModels addObject:model];
  }
  return newModels;
}

- (void)appendNewRenderModels:(NSArray<GDDRenderModel *> *)newModels {
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

- (void)updateRenderModel:(id <GDCMessage>)message withModelId:(NSString *)mid {
  GDDRenderModel *model = [self.dataSource renderModelForId:mid];
  if ([model.render respondsToSelector:@selector(handleMessage:)]) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [model.render handleMessage:message];
    });
  }
}

@end
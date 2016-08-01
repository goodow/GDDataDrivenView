//
// Created by Larry Tin on 7/31/16.
//

#import "GDDBaseViewLayout.h"
#import "GDDModel.h"
#import "GDCMessage.h"
#import "GDCMessageConsumer.h"
#import "NSObject+GDChannel.h"
#import "GDDBaseViewDataSource.h"
#import "SVPullToRefresh.h"

static NSString *const modelsPath = @"models";
static NSString *const sectionsPath = @"sections";

@interface GDDBaseViewLayout ()

@end

@implementation GDDBaseViewLayout {
  id <GDCMessageConsumer> _consumer;
}

- (instancetype)initWithTopic:(NSString *)layoutTopic withView:(id)view {
  self = [super init];
  if (self) {
    _view = view;
    _modelsTopic = [[layoutTopic stringByAppendingPathComponent:modelsPath] stringByAppendingString:@"/"];
    _sectionsTopic = [[layoutTopic stringByAppendingPathComponent:sectionsPath] stringByAppendingString:@"/"];
    // 设置topic
    [self setTopic:layoutTopic];
  }
  return self;
}

- (void)dealloc {
  [_consumer unsubscribe];
  _consumer = nil;
//  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)setTopic:(NSString *)layoutTopic {
  __weak GDDBaseViewLayout *weakSelf = self;
  NSString *wildcardTopic = [layoutTopic stringByAppendingPathComponent:@"#"];
  _consumer = [self.bus subscribeLocal:wildcardTopic handler:^(id <GDCMessage> message) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          if (!weakSelf) {
//            NSLog(@"weakSelf is nil");
            return;
          }
          NSString *topic = message.topic;
          if ([topic hasPrefix:weakSelf.sectionsTopic]) {
            NSInteger section = [topic substringFromIndex:weakSelf.sectionsTopic.length].integerValue;
            [weakSelf reloadModels:message.payload forSection:section];
            return;
          }
          if ([topic hasPrefix:weakSelf.modelsTopic]) {
            NSString *mid = [topic substringFromIndex:weakSelf.modelsTopic.length];
            [weakSelf reloadModel:message forId:mid];
            return;
          }
      });
  }];
}

- (NSString *)topicForSection:(NSInteger)section {
  return [self.sectionsTopic stringByAppendingPathComponent:@(section).stringValue];
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
  NSMutableArray *indexPaths = [self generateNewIndexPaths:models.count fromRow:0];
  [self.dataSource insertModels:models atIndexPaths:indexPaths];
  __weak id view = self.view;
  dispatch_async(dispatch_get_main_queue(), ^{
//      [view reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
      [view reloadData];
  });
}

- (NSArray<GDDModel *> *)diffMatch { //  oldRowCount:(int *)oldRowCount {
  NSInteger sectionsCount = self.dataSource.numberOfSections;
  NSInteger lastSection = sectionsCount ? sectionsCount - 1 : 0;
  NSInteger rowsInLastSection = sectionsCount ? [self.dataSource numberOfItemsInSection:lastSection] : 0;
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
  NSMutableArray *indexPaths = [self generateNewIndexPaths:newModels.count fromRow:-1];
  [self.dataSource insertModels:newModels atIndexPaths:indexPaths];
  __weak UIScrollView *view = self.view;
//  NSArray<NSIndexPath *> *visibleRows = [tableView indexPathsForVisibleRows];
//  NSComparisonResult result1 = [indexPaths.firstObject compare:visibleRows.firstObject];
//  if (result1 == NSOrderedSame || result1 == NSOrderedDescending) {
//    NSComparisonResult result2 = [indexPaths.firstObject compare:visibleRows.lastObject];
//    if (result2 == NSOrderedSame || result2 == NSOrderedAscending) {
//      // cell is visible, reload immediately
  dispatch_async(dispatch_get_main_queue(), ^{
      if ([view isKindOfClass:UITableView.class]) {
        UITableView *tableView = view;
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
      } else if ([view isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = view;
        [collectionView performBatchUpdates:^{
            [collectionView insertItemsAtIndexPaths:indexPaths];
        }                        completion:nil];
      }
      if (view.infiniteScrollingView.state == SVInfiniteScrollingStateLoading) {
        [view.infiniteScrollingView stopAnimating];
      }
  });
//    }
//  }
}

- (NSMutableArray *)generateNewIndexPaths:(int)count fromRow:(NSInteger)row {
  NSMutableArray *indexPaths = @[].mutableCopy;
  NSInteger sectionsCount = self.dataSource.numberOfSections;
  NSInteger lastSection = sectionsCount ? sectionsCount - 1 : 0;
  if (row == -1) {
    row = sectionsCount ? [self.dataSource numberOfItemsInSection:lastSection] : 0;
  }
  for (int i = 0; i < count; i++) {
    [indexPaths addObject:[NSIndexPath indexPathForRow:row++ inSection:lastSection]];
  }
  return indexPaths;
}

- (void)reloadModel:(id <GDCMessage>)msg forId:(NSString *)mid {
  id patch = msg.payload;
  NSIndexPath *indexPath = [self.dataSource indexPathForId:mid];
  GDDModel *model = [self.dataSource modelForIndexPath:indexPath];
  if ([patch isKindOfClass:NSDictionary.class]) {
    [model mergeFromJson:patch];
  } else {
    [model mergeFrom:patch];
  }
  id <GDDRender> render;
  if ([self.view isKindOfClass:UITableView.class]) {
    render = [(UITableView *) self.view cellForRowAtIndexPath:indexPath];
  } else if ([self.view isKindOfClass:UICollectionView.class]) {
    render = [(UICollectionView *) self.view cellForItemAtIndexPath:indexPath];
  }
  __weak GDDBaseViewLayout *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.dataSource reloadModel:model forRender:render];
      if ([weakSelf.view isKindOfClass:UITableView.class]) {
        [(UITableView *) weakSelf.view reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      } else if ([weakSelf.view isKindOfClass:UICollectionView.class]) {
        [(UICollectionView *) weakSelf.view reloadItemsAtIndexPaths:@[indexPath]];
      }
  });
}

#pragma mark Event Handler

- (void)setInfiniteScrollingHandler:(id)infiniteScrollingHandler {
  if (!infiniteScrollingHandler) {
    _infiniteScrollingHandler = nil;
    self.view.showsInfiniteScrolling = NO;
    return;
  }
  _infiniteScrollingHandler = [infiniteScrollingHandler copy];
  __weak GDDBaseViewLayout *weakSelf = self;
  [self.view addInfiniteScrollingWithActionHandler:^{
      if (weakSelf.infiniteScrollingHandler) {
        weakSelf.infiniteScrollingHandler(weakSelf.models.copy, ^(BOOL hasMore) {
            [weakSelf.view.infiniteScrollingView stopAnimating];
            if (!hasMore) {
              weakSelf.view.showsInfiniteScrolling = NO;
            }
        });
      }
  }];
}
@end
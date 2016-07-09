//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewLayout.h"
#import "GDDTableViewDataSource.h"
#import "NSObject+GDChannel.h"
#import "GDDRenderModel.h"

@interface GDDTableViewLayout () <UITableViewDelegate>
@property(nonatomic) GDDTableViewDataSource *dataSource;
@end

@implementation GDDTableViewLayout {
  id <GDCMessageConsumer> _consumer;
  __weak UITableView *_tableView;
}
- (instancetype)initWithTableView:(UITableView *)tableView {
  self = [super init];
  if (self) {
    _tableView = tableView;
    _dataSource = [[GDDTableViewDataSource alloc] init];
    tableView.dataSource = _dataSource;
    tableView.delegate = self;
  }

  return self;
}

- (void)dealloc {
  [_consumer unsubscribe];
  _consumer = nil;
}

- (void)setTopic:(NSString *)topic {
  if (_topic && [_topic isEqualToString:topic]) {
    return;
  }
  _topic = topic;
  __weak GDDTableViewLayout *weakSelf = self;
  NSString *wildcardTopic = [topic stringByAppendingPathComponent:@"#"];
  _consumer = [self.bus subscribeLocal:wildcardTopic handler:^(id <GDCMessage> message) {
      if (![message.topic hasPrefix:[topic stringByAppendingPathComponent:@""]]) {
        return;
      }
      GDDRenderModel *model = [weakSelf.dataSource renderModelForTopic:message.topic];
      if ([model.render respondsToSelector:@selector(handleMessage:)]) {
        [model.render handleMessage:message];
      }
  }];
}

#pragma mark UITableViewDelegate

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  GDDRenderModel *model = [self.dataSource renderModelForIndexPath:indexPath];
  if (model.tapHandler) {
    model.tapHandler(model, nil);
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44;
}


@end

//
//  Created by Larry Tin on 07/09/2016.
//

#import "GDDViewController.h"
#import "GDDTableViewLayout.h"
#import "NSObject+GDChannel.h"
#import "GDCBusProvider.h"

#define xyzLayoutTopic [GDCBusProvider.clientId stringByAppendingPathComponent:@"abcView/layouts/xyzTable"]

@interface GDDViewController ()
@property(nonatomic) GDDTableViewLayout *layout;
@end

@implementation GDDViewController {
}

- (void)viewDidLoad {
  [self.bus subscribe:[GDCBusProvider.clientId stringByAppendingPathComponent:@"#"] handler:^(id <GDCMessage> message) {

  }];
  __weak GDDViewController *weakSelf = self;
  self.layout = [[GDDTableViewLayout alloc] initWithTableView:self.tableView withTopic:xyzLayoutTopic];
  self.layout.tapHandler = ^(GDDModel *model, UITapGestureRecognizer *sender) {
      GDCOptions *opt = [[GDCOptions alloc] init];
      opt.patch = YES;
      opt.type = @"GDDModel";
      GDDModel *copy = [[GDDModel alloc] initWithData:model.data withId:nil withNibNameOrRenderClass:model.renderType];
      [NSObject.bus publishLocal:xyzLayoutTopic payload:@[copy] options:opt];
  };
  self.layout.infiniteScrollingHandler = ^(NSArray<GDDModel *> *models, void (^complete)()) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
          // 加载完成后结束动画
          complete();
          // 当不再需要无限滚动翻页时, 将infiniteScrollingHandler设置为nil
          weakSelf.layout.infiniteScrollingHandler = nil;
      });
  };

  [self requestJsonModels:^(NSArray<NSDictionary *> *array) {
      NSArray *models = [GDDViewController createModelsFromJsonArray:array];
      [NSObject.bus publishLocal:xyzLayoutTopic payload:models];
  }];

  [super viewDidLoad];
}

- (void)requestJsonModels:(void (^)(NSArray<NSDictionary *> *))callback {
  // Simulate an async request
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      // Data from `test_data.json`
      NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"test_data" ofType:@"json"];
      NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
      NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
      // Callback
      dispatch_async(dispatch_get_main_queue(), ^{
          !callback ?: callback(json);
      });
  });
}

+ (NSArray<GDDModel *> *)createModelsFromJsonArray:(NSArray *)array {
  NSMutableArray<GDDModel *> *models = [NSMutableArray array];
  for (NSDictionary *json in array) {
    GDDModel *model = [[GDDModel alloc] initWithData:json[@"data"] withId:json[@"mid"] withNibNameOrRenderClass:json[@"renderType"]];
    [models addObject:model];
  }
  return models;
}
@end

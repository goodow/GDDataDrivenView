//
//  Created by Larry Tin on 07/09/2016.
//

#import "GDDViewController.h"
#import "GDDTableViewLayout.h"
#import "NSObject+GDChannel.h"
#import "GDDModel.h"
#import "Channel.pbobjc.h"
#import "GPBMessage+JsonFormat.h"
#import "GDCBusProvider.h"

#define xyzLayoutTopic [GDCBusProvider.clientId stringByAppendingPathComponent:@"abcView/layouts/xyzTable"]

@interface GDDViewController ()
@property(nonatomic, copy) NSArray *json;
@end

@implementation GDDViewController {
  GDDTableViewLayout *_layout;
}

- (void)viewDidLoad {
  [self.bus subscribe:[GDCBusProvider.clientId stringByAppendingPathComponent:@"#"] handler:^(id <GDCMessage> message) {

  }];
  _layout = [[GDDTableViewLayout alloc] initWithTableView:self.tableView withTopic:xyzLayoutTopic];

  [self requestJsonModels:^(NSArray<NSDictionary *> *array) {
      NSArray *models = [GDDViewController createModelsFromJsonArray:array];
      [NSObject.bus publishLocal:xyzLayoutTopic payload:models];
  }];

  [super viewDidLoad];

  GDCPBOptions *options = [GDCPBOptions message];
  options.viewOptions.statusBarStyle = 3;
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
    model.tapHandler = ^(GDDModel *model, UITapGestureRecognizer *sender) {
        GDCOptions *opt = [[GDCOptions alloc] init];
        opt.patch = YES;
        opt.type = @"GDDModel";
        [NSObject.bus publishLocal:xyzLayoutTopic payload:@[model] options:opt];
    };
  }
  return models;
}
@end

//
//  Created by Larry Tin on 07/09/2016.
//

#import "GDDViewController.h"
#import "GDDTableViewLayout.h"
#import "NSObject+GDChannel.h"
#import "GDDRenderModel.h"
#import "GDDTableViewCellRender.h"
#import "Channel.pbobjc.h"
#import "GPBMessage+JsonFormat.h"
#import "GDCBusProvider.h"

@interface GDDViewController ()
@property(nonatomic, copy) NSArray *json;
@end

@implementation GDDViewController {
  GDDTableViewLayout *_layout;
  NSString *_topic;
}

- (void)viewDidLoad {
  _topic = [GDCBusProvider.clientId stringByAppendingPathComponent:@"GDDViewController"];
  [self.bus subscribe:[GDCBusProvider.clientId stringByAppendingPathComponent:@"#"] handler:^(id <GDCMessage> message) {

  }];
  _layout = [[GDDTableViewLayout alloc] initWithTableView:self.tableView withTopic:_topic];

  [self requestJsonModels:^(NSArray<NSDictionary *> *array) {
      NSArray *models = [GDDViewController createRenderModelsFromJsonArray:array];
      [NSObject.bus publishLocal:_topic payload:models];
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
      NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      // Callback
      dispatch_async(dispatch_get_main_queue(), ^{
          !callback ?: callback(json);
      });
  });
}

+ (NSArray<GDDRenderModel *> *)createRenderModelsFromJsonArray:(NSArray *)array {
  NSMutableArray<GDDRenderModel *> *models = [NSMutableArray array];
  for (NSDictionary *json in array) {
    Class renderClass = NSClassFromString(json[@"renderClass"]);
    GDDRenderModel *model = [[GDDRenderModel alloc] initWithData:json[@"data"] withId:json[@"mid"] withRenderClass:renderClass];
    [models addObject:model];
    model.tapHandler = ^(GDDRenderModel *renderModel, UITapGestureRecognizer *sender) {
        GDCOptions *opt = [[GDCOptions alloc] init];
        opt.patch = YES;
        opt.type = @"GDDRenderModel";
        [NSObject.bus publishLocal:[GDCBusProvider.clientId stringByAppendingPathComponent:@"GDDViewController"] payload:@[model] options:opt];
    };
  }
  return models;
}
@end

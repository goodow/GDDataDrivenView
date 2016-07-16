//
// Created by Larry Tin on 16/7/11.
//

#import "GDDTableViewDelegate.h"
#import "GDDRenderModel.h"
#import "GDDTableViewDataSource.h"
//#import "UITableView+FDTemplateLayoutCell.h"
#import "NSObject+GDChannel.h"
#import "GDCMessageImpl.h"

@implementation GDDTableViewDelegate {

}


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
  GDDRenderModel *model = [self.dataSource renderModelForIndexPath:indexPath];
  return 88;
//  return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(model.renderClass) cacheByKey:model.topic configuration:^(UITableViewCell *cell) {
//  return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(model.renderClass) configuration:^(UITableViewCell *cell) {
//      GDCMessageImpl *message = [[GDCMessageImpl alloc] init];
//      message.topic = model.topic;
//      message.local = YES;
//      message.payload = model;
//      [cell handleMessage:message];
//  }];
}


@end
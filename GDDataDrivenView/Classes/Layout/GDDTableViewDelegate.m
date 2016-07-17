//
// Created by Larry Tin on 16/7/11.
//

#import "GDDTableViewDelegate.h"
#import "GDDModel.h"
#import "GDDTableViewDataSource.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NSObject+GDChannel.h"

@implementation GDDTableViewDelegate {
  __weak GDDTableViewDataSource *_dataSource;
}

- (instancetype)initWithDataSource:(GDDTableViewDataSource *)dataSource{
  self = [super init];
  if (self) {
    _dataSource = dataSource;
  }

  return self;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  GDDModel *model = [_dataSource modelForIndexPath:indexPath];
  if (model.tapHandler) {
    model.tapHandler(model, nil);
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDModel *model = [_dataSource modelForIndexPath:indexPath];
  return [tableView fd_heightForCellWithIdentifier:model.renderType cacheByKey:model.mid configuration:^(UITableViewCell *cell) {
//  return [tableView fd_heightForCellWithIdentifier:model.renderType configuration:^(UITableViewCell *cell) {
      [model reloadData];
  }];
}

@end
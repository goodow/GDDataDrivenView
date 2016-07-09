//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewDataSource.h"
#import "GDDRenderModel.h"
#import "NSObject+GDChannel.h"
#import "GDCMessageImpl.h"

@interface GDDTableViewDataSource ()
@end

@implementation GDDTableViewDataSource {
  NSMutableArray<NSMutableArray<GDDRenderModel *> *> *_renderModels;
}

- (GDDRenderModel *)renderModelForIndexPath:(NSIndexPath *)indexPath {
  int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
  return _renderModels[indexPath.section][indexPath.row + hasHeading];
}

- (GDDRenderModel *)renderModelForTopic:(NSString *)topic {
  for (NSArray *models in _renderModels) {
    for (GDDRenderModel *model in models) {
      if ([model.topic isEqualToString:topic]) {
        return model;
      }
    }
  }
  return nil;
}

- (NSIndexPath *)indexPathForTopic:(NSString *)topic {
  NSInteger sectionsCount = [self numberOfSectionsInTableView:nil];
  for (NSUInteger sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++) {
    NSArray *section = _renderModels[sectionIndex];
    int hasHeading = [self _sectionHasHeading:sectionIndex] ? 1 : 0;
    for (NSUInteger rowIndex = hasHeading ? 1 : 0; rowIndex < section.count; rowIndex++) {
      GDDRenderModel *model = section[rowIndex];
      if ([model.topic isEqualToString:topic]) {
        return [NSIndexPath indexPathForRow:rowIndex - hasHeading inSection:sectionIndex];
      }
    }
  }
  return nil;
}

- (GDDRenderModel *)headerRenderModelForSection:(NSInteger)section {
  GDDRenderModel *model = _renderModels[section][0];
  if (!model.renderClass && !model.topic && !model.render) {
    return model;
  }
  return nil;
}

- (BOOL)_sectionHasHeading:(NSInteger)section {
  return [self headerRenderModelForSection:section] != nil;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDRenderModel *model = [self renderModelForIndexPath:indexPath];
  Class renderClass = model.renderClass;
  if (model.render) {
    return model.render;
  }
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(renderClass)];
  if (!cell) {
    cell = [renderClass instancesRespondToSelector:@selector(initWithPayload:)] ?
        [[renderClass alloc] initWithPayload:model] : [[renderClass alloc] init];
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tapGesture.cancelsTouchesInView = NO;
//    [cell addGestureRecognizer:tapGesture];
  } else if ([cell respondsToSelector:@selector(handleMessage:)]) {
    GDCMessageImpl *message = [[GDCMessageImpl alloc] init];
    message.topic = model.topic;
    message.local = YES;
    message.payload = model;
    [cell handleMessage:message];
  }
  model.render = cell;
  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _renderModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int hasHeading = [self _sectionHasHeading:section] ? 1 : 0;
  return [_renderModels[section] count] - hasHeading;
}

#pragma mark Event Handler
- (void)handleTap:(UITapGestureRecognizer *)sender {

}
@end

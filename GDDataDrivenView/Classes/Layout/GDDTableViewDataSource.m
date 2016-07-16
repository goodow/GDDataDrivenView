//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewDataSource.h"
#import "GDDRenderModel.h"
#import "NSObject+GDChannel.h"
#import "GDCMessageImpl.h"
#import "GDDRender.h"

@interface GDDTableViewDataSource ()
@end

@implementation GDDTableViewDataSource {
  __weak NSString *_topic;
  NSMutableArray<NSMutableArray<GDDRenderModel *> *> *_renderModels;
}

- (instancetype)initWithTopic:(NSString *)topic {
  self = [super init];
  if (self) {
    _topic = topic;
    _renderModels = @[].mutableCopy;
  }

  return self;
}

#pragma mark Read model
- (GDDRenderModel *)renderModelForIndexPath:(NSIndexPath *)indexPath {
  int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
  return _renderModels[indexPath.section][indexPath.row + hasHeading];
}

- (GDDRenderModel *)renderModelForId:(NSString *)mid {
  for (NSArray *models in _renderModels) {
    for (GDDRenderModel *model in models) {
      if ([model.mid isEqualToString:mid]) {
        return model;
      }
    }
  }
  return nil;
}

- (NSIndexPath *)indexPathForId:(NSString *)mid {
  NSInteger sectionsCount = [self numberOfSectionsInTableView:nil];
  for (NSUInteger sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++) {
    NSArray *section = _renderModels[sectionIndex];
    int hasHeading = [self _sectionHasHeading:sectionIndex] ? 1 : 0;
    for (NSUInteger rowIndex = hasHeading ? 1 : 0; rowIndex < section.count; rowIndex++) {
      GDDRenderModel *model = section[rowIndex];
      if ([model.mid isEqualToString:mid]) {
        return [NSIndexPath indexPathForRow:rowIndex - hasHeading inSection:sectionIndex];
      }
    }
  }
  return nil;
}

- (GDDRenderModel *)headerRenderModelForSection:(NSInteger)section {
  NSInteger sectionCount = [self numberOfSectionsInTableView:nil];
  if (section >= sectionCount || _renderModels[section].count == 0) {
    return nil;
  }
  GDDRenderModel *model = _renderModels[section][0];
  if (!model.renderClass && !model.mid && !model.render) {
    return model;
  }
  return nil;
}

- (BOOL)_sectionHasHeading:(NSInteger)section {
  return [self headerRenderModelForSection:section] != nil;
}

#pragma mark Change model

- (void)insertModels:(NSArray<GDDRenderModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  int i = 0;
  for (NSIndexPath *indexPath in indexPaths) {
    if (indexPath.section == [self numberOfSectionsInTableView:nil]) {
      [_renderModels addObject:@[].mutableCopy];
    }
    int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
    [_renderModels[indexPath.section] insertObject:models[i++] atIndex:indexPath.row + hasHeading];
  }
}

- (void)clearModels {
  [_renderModels removeAllObjects];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDRenderModel *model = [self renderModelForIndexPath:indexPath];
  Class renderClass = model.renderClass;
  if (model.render) {
    return model.render;
  }
  UITableViewCell *cellRender = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(renderClass)];
  BOOL initWithPayload = NO;
  if (!cellRender) {
    initWithPayload = [renderClass instancesRespondToSelector:@selector(initWithPayload:)];
    cellRender = initWithPayload ? [[renderClass alloc] initWithPayload:model] : [[renderClass alloc] init];
  }
  if (!initWithPayload && [cellRender respondsToSelector:@selector(handleMessage:)]) {
    GDCMessageImpl *message = [[GDCMessageImpl alloc] init];
    message.topic = [_topic stringByAppendingPathComponent:model.mid];
    message.local = YES;
    message.payload = model;
    [cellRender handleMessage:message];
  }
  model.render = cellRender;
  for (UIGestureRecognizer *gestureRecognizer in cellRender.gestureRecognizers) {
    [cellRender removeGestureRecognizer:gestureRecognizer];
  }
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:model action:@selector(handleTap:)];
  tapGesture.cancelsTouchesInView = NO;
  [cellRender addGestureRecognizer:tapGesture];
  return cellRender;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _renderModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section >= _renderModels.count) {
    return 0;
  }
  int hasHeading = [self _sectionHasHeading:section] ? 1 : 0;
  return [_renderModels[section] count] - hasHeading;
}

//#pragma mark Event Handler
@end

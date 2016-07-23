//
//  Created by Larry Tin on 7/9/16.
//

#import <objc/runtime.h>
#import "GDDTableViewDataSource.h"
#import "GDDModel.h"
#import "NSObject+GDChannel.h"
#import "GDDTableViewLayout.h"
#import "GDDRender.h"

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kPresenterKey = 0;

@interface GDDTableViewDataSource ()
@property(nonatomic, weak) GDDTableViewLayout *layout;
@end

@implementation GDDTableViewDataSource {
  NSMutableArray<NSMutableArray<GDDModel *> *> *_models;
  NSMutableDictionary<NSString *, UINib *> *_registeredNibsForCellReuseIdentifier;
  NSMutableDictionary<NSString *, Class> *_registeredClassForCellReuseIdentifier;
  __weak UITableView *_tableView;
  __weak id _ownerView;
  NSMapTable *_presentersByClass;
}

- (instancetype)initWithTableView:(UITableView *)tableView withLayout:(GDDTableViewLayout *)layout withOwnerView:(id)ownerView {
  self = [super init];
  if (self) {
    _tableView = tableView;
    _layout = layout;
    _ownerView = ownerView;
    _models = @[].mutableCopy;
    _registeredNibsForCellReuseIdentifier = @{}.mutableCopy;
    _registeredClassForCellReuseIdentifier = @{}.mutableCopy;
    _presentersByClass = [NSMapTable weakToWeakObjectsMapTable];
  }

  return self;
}

#pragma mark Read model

- (GDDModel *)modelForIndexPath:(NSIndexPath *)indexPath {
  int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
  return _models[indexPath.section][indexPath.row + hasHeading];
}

- (GDDModel *)modelForId:(NSString *)mid {
  for (NSArray *models in _models) {
    for (GDDModel *model in models) {
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
    NSArray *section = _models[sectionIndex];
    int hasHeading = [self _sectionHasHeading:sectionIndex] ? 1 : 0;
    for (NSUInteger rowIndex = hasHeading ? 1 : 0; rowIndex < section.count; rowIndex++) {
      GDDModel *model = section[rowIndex];
      if ([model.mid isEqualToString:mid]) {
        return [NSIndexPath indexPathForRow:rowIndex - hasHeading inSection:sectionIndex];
      }
    }
  }
  return nil;
}

- (GDDModel *)headerModelForSection:(NSInteger)section {
  NSInteger sectionCount = [self numberOfSectionsInTableView:nil];
  if (section >= sectionCount || _models[section].count == 0) {
    return nil;
  }
  GDDModel *model = _models[section][0];
  if (!model.renderType && !model.mid) {
    return model;
  }
  return nil;
}

- (BOOL)_sectionHasHeading:(NSInteger)section {
  return [self headerModelForSection:section] != nil;
}

#pragma mark Change model

- (void)insertModels:(NSArray<GDDModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  int i = 0;
  for (NSIndexPath *indexPath in indexPaths) {
    if (indexPath.section == [self numberOfSectionsInTableView:nil]) {
      [_models addObject:@[].mutableCopy];
    }
    int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
    GDDModel *model = models[i++];
    [_models[indexPath.section] insertObject:model atIndex:indexPath.row + hasHeading];
    NSString *name = model.renderType;
    if (_registeredNibsForCellReuseIdentifier[name] || _registeredClassForCellReuseIdentifier[name]) {
      continue;
    }
    if ([[NSBundle mainBundle] pathForResource:name ofType:@"nib"]) {
      UINib *nib = [UINib nibWithNibName:name bundle:nil];
      _registeredNibsForCellReuseIdentifier[name] = nib;
      [_tableView registerNib:nib forCellReuseIdentifier:name];
      continue;
    }
    Class cellClass = NSClassFromString(name);
#ifdef DEBUG
    if (!cellClass || ![cellClass isKindOfClass:UITableViewCell.class]) {
      [NSException raise:NSInvalidArgumentException format:@"Class with name '%@' is not found or not a kind of UITableViewCell", name];
    }
#endif
    _registeredClassForCellReuseIdentifier[name] = cellClass;
    [_tableView registerClass:cellClass forCellReuseIdentifier:name];
  }
}

- (void)clearModels {
  [_models removeAllObjects];

}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _models.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section >= _models.count) {
    return 0;
  }
  int hasHeading = [self _sectionHasHeading:section] ? 1 : 0;
  return [_models[section] count] - hasHeading;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDModel *model = [self modelForIndexPath:indexPath];
  UITableViewCell <GDDRender> *cell = [tableView dequeueReusableCellWithIdentifier:model.renderType];

  // Configure the cell for this indexPath
  [self reloadModel:model forRender:cell];

  // Make sure the constraints have been added to this cell, since it may have just been created from scratch
#if SelfSizing_UpdateConstraints
  [cell setNeedsUpdateConstraints];
  [cell updateConstraintsIfNeeded];
#endif
  return cell;
}

- (id <GDDPresenter>)reloadModel:(GDDModel *)model forRender:(UITableViewCell <GDDRender> *)render {
  id <GDDPresenter> presenter = objc_getAssociatedObject(render, &kPresenterKey);
  if (!presenter) {
    Class presenterClass = render.presenterClass;
    presenter = [_presentersByClass objectForKey:presenterClass];
    if (!presenter) {
      if ([presenterClass instancesRespondToSelector:@selector(initWithOwnerView:)]) {
        presenter = [(id <GDDPresenter>) [presenterClass alloc] initWithOwnerView:_ownerView];
      } else {
        presenter = [[presenterClass alloc] init];
      }
    }
    objc_setAssociatedObject(render, &kPresenterKey, presenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  [presenter update:render withModel:model];
  return presenter;
}
@end

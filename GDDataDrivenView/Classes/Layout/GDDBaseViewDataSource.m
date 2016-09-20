//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDBaseViewDataSource.h"
#import <objc/runtime.h>
#import "GDDModel.h"
#import "NSObject+GDChannel.h"
#import "GDDRender.h"
#import "GDDRenderPresenter.h";

// The address of this variable is used as a key for obj_getAssociatedObject.
static const char kPresenterKey = 0;

@interface GDDBaseViewDataSource ()
@end

@implementation GDDBaseViewDataSource {
  NSMutableArray<NSMutableArray<GDDModel *> *> *_models;
  NSMutableDictionary<NSString *, UINib *> *_registeredNibsForCellReuseIdentifier;
  NSMutableDictionary<NSString *, Class> *_registeredClassForCellReuseIdentifier;
  __weak id _owner;
  NSMapTable *_presentersByClass;
}

- (instancetype)initWithView:(id)view withOwner:(id)owner {
  self = [super init];
  if (self) {
    _owner = owner;
    _view = view;
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
  return _models[indexPath.section][indexPath.item + hasHeading];
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
  NSInteger sectionsCount = [self numberOfSections];
  for (NSUInteger sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++) {
    NSArray *section = _models[sectionIndex];
    int hasHeading = [self _sectionHasHeading:sectionIndex] ? 1 : 0;
    for (NSUInteger itemIndex = hasHeading ? 1 : 0; itemIndex < section.count; itemIndex++) {
      GDDModel *model = section[itemIndex];
      if ([model.mid isEqualToString:mid]) {
        return [NSIndexPath indexPathForItem:itemIndex - hasHeading inSection:sectionIndex];
      }
    }
  }
  return nil;
}

- (GDDModel *)headerModelForSection:(NSInteger)section {
  NSInteger sectionCount = [self numberOfSections];
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

- (NSInteger)numberOfSections {
  return _models.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
  if (section >= _models.count) {
    return 0;
  }
  int hasHeading = [self _sectionHasHeading:section] ? 1 : 0;
  return [_models[section] count] - hasHeading;
}

#pragma mark Change model

- (void)insertModels:(NSArray<GDDModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  int i = 0;
  for (NSIndexPath *indexPath in indexPaths) {
    if (indexPath.section == [self numberOfSections]) {
      [_models addObject:@[].mutableCopy];
    }
    int hasHeading = [self _sectionHasHeading:indexPath.section] ? 1 : 0;
    GDDModel *model = models[i++];
    [_models[indexPath.section] insertObject:model atIndex:indexPath.item + hasHeading];
    NSString *name = model.renderType;
    if (_registeredNibsForCellReuseIdentifier[name] || _registeredClassForCellReuseIdentifier[name]) {
      continue;
    }
    if ([NSBundle.mainBundle pathForResource:name ofType:@"nib"]) {
      UINib *nib = [UINib nibWithNibName:name bundle:nil];
      _registeredNibsForCellReuseIdentifier[name] = nib;
      if ([_view isKindOfClass:UITableView.class]) {
        [_view registerNib:nib forCellReuseIdentifier:name];
      } else if ([_view isKindOfClass:UICollectionView.class]) {
        [_view registerNib:nib forCellWithReuseIdentifier:name];
      }
      continue;
    }
    Class cellClass = NSClassFromString(name);
#ifdef DEBUG
    if (!cellClass || (![cellClass isSubclassOfClass:UITableViewCell.class] && ![cellClass isSubclassOfClass:UICollectionViewCell.class])) {
      [NSException raise:NSInvalidArgumentException format:@"Class with name '%@' is not found or not a kind of UITableViewCell/UICollectionViewCell", name];
    }
#endif
    _registeredClassForCellReuseIdentifier[name] = cellClass;
    if ([_view isKindOfClass:UITableView.class]) {
      [_view registerClass:cellClass forCellReuseIdentifier:name];
    } else if ([_view isKindOfClass:UICollectionView.class]) {
      [_view registerClass:cellClass forCellWithReuseIdentifier:name];
    }
  }
}

- (void)clearModels {
  [_models removeAllObjects];
}

- (id <GDDRenderPresenter>)reloadModel:(GDDModel *)model forRender:(NSObject <GDDRender> *)render {
  id <GDDRenderPresenter> presenter;
  if ([render respondsToSelector:@selector(presenter)]) {
    presenter = render.presenter;
  } else {
    presenter = objc_getAssociatedObject(render, &kPresenterKey);
    if (!presenter) { // 使用命名约定查询或创建Presenter: AbcRender -> AbcPresenter
      Class presenterClass;
      NSString *renderClassName = NSStringFromClass([render class]);
      NSString *presenterClassName;
      const NSString *renderSuffix = @"Render";
      if ([renderClassName hasSuffix:renderSuffix]) {
        presenterClassName = [renderClassName substringToIndex:renderClassName.length - renderSuffix.length];
        presenterClass = NSClassFromString([NSString stringWithFormat:@"%@Presenter", presenterClassName]);
      }
      if (!presenterClass) {
        [NSException raise:NSInvalidArgumentException format:@"Could not find a presenter class named '%@' for %@", presenterClassName, renderClassName];
      }
      presenter = [_presentersByClass objectForKey:presenterClass];
      if (!presenter) {
        if ([presenterClass instancesRespondToSelector:@selector(initWithOwner:)]) {
          presenter = [(id <GDDRenderPresenter>) [presenterClass alloc] initWithOwner:_owner];
        } else {
          presenter = [[presenterClass alloc] init];
        }
        [_presentersByClass setObject:presenter forKey:presenterClass];
      }
      objc_setAssociatedObject(render, &kPresenterKey, presenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
  }

  [presenter update:render withData:model.data];
  return presenter;
}
@end

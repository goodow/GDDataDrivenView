//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewDataSource.h"
#import "GDDModel.h"
#import "NSObject+GDChannel.h"
#import "GDDTableViewLayout.h"
#import "GDDRender.h"
#import <objc/runtime.h>

@interface GDDTableViewDataSource ()
@property(nonatomic, weak) GDDTableViewLayout *layout;
@end

@implementation GDDTableViewDataSource {
}

- (instancetype)initWithTableView:(UITableView *)tableView withLayout:(GDDTableViewLayout *)layout withOwner:(id)owner {
  self = [super initWithView:tableView withOwner:owner];
  if (self) {
    _layout = layout;
  }
  return self;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [super numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [super numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GDDModel *model = [super modelForIndexPath:indexPath];
  UITableViewCell <GDDRender> *cell = [tableView dequeueReusableCellWithIdentifier:model.renderType];
  // Configure the cell for this indexPath
  [super reloadModel:model forRender:cell];

#if SelfSizing_UpdateConstraints
  // Make sure the constraints have been added to this cell, since it may have just been created from scratch
  [cell setNeedsUpdateConstraints];
  [cell updateConstraintsIfNeeded];
#else
  objc_setAssociatedObject(model, &kRenderKey, cell, OBJC_ASSOCIATION_ASSIGN);
#endif
  return cell;
}

#if !(SelfSizing_UpdateConstraints)
static const char kRenderKey = 0;
- (UITableViewCell *)renderForModel:(GDDModel *)model {
  return objc_getAssociatedObject(model, &kRenderKey);
}
#endif

@end
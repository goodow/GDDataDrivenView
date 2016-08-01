//
//  Created by Larry Tin on 7/9/16.
//

#import "GDDTableViewDataSource.h"
#import "GDDModel.h"
#import "NSObject+GDChannel.h"
#import "GDDTableViewLayout.h"
#import "GDDRender.h"

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

  // Make sure the constraints have been added to this cell, since it may have just been created from scratch
#if SelfSizing_UpdateConstraints
  [cell setNeedsUpdateConstraints];
  [cell updateConstraintsIfNeeded];
#else
  //  objc_setAssociatedObject(model, &kPresenterKey2, cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    model.render = cell;
#endif
  return cell;
}
@end

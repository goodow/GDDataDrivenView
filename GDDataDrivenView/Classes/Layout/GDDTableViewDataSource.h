//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>
#import "GDDBaseViewDataSource.h"

@class GDDTableViewLayout;

#define SelfSizing_UpdateConstraints 1

@interface GDDTableViewDataSource : GDDBaseViewDataSource <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView withLayout:(GDDTableViewLayout *)layout withOwner:(id)owner;

#if !(SelfSizing_UpdateConstraints)
- (UITableViewCell *)renderForModel:(GDDModel *)model;
#endif
@end

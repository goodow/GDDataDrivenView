//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>
#import "GDDModel.h"
#import "GDDBaseViewLayout.h"

@interface GDDTableViewLayout : GDDBaseViewLayout

- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)layoutTopic withOwner:(id)owner;

@end

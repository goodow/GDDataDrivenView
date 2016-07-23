//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>
#import "GDDModel.h"

@interface GDDTableViewLayout : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)layoutTopic withOwnerView:(id)ownerView;

- (NSString *)topicForSection:(NSInteger)section;

@property(nonatomic, copy) void (^infiniteScrollingHandler)(NSArray<GDDModel *> *models, void (^loadComplete)(BOOL hasMore));

@end

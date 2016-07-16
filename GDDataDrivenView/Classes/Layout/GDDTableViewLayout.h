//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>

@class GDDTableViewDataSource;

@interface GDDTableViewLayout : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView withTopic:(NSString *)topic;

@property(nonatomic, readonly) NSString *topic;

@end

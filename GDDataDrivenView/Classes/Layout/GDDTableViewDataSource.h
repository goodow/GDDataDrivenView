//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>
#import "GDDBaseViewDataSource.h"

@class GDDModel;
@protocol GDDRender;
@protocol GDCMessage;
@class GDDTableViewLayout;
@protocol GDDPresenter;

#define SelfSizing_UpdateConstraints 1
//static const char kPresenterKey2 = 0;

@interface GDDTableViewDataSource : GDDBaseViewDataSource <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView withLayout:(GDDTableViewLayout *)layout withOwner:(id)owner;

@end

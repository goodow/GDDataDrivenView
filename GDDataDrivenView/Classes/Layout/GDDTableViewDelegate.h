//
// Created by Larry Tin on 16/7/11.
//

#import <Foundation/Foundation.h>

@class GDDTableViewDataSource;


@interface GDDTableViewDelegate : NSObject <UITableViewDelegate>

- (instancetype)initWithDataSource:(GDDTableViewDataSource *)dataSource;
@end
//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>

@class GDDModel;
@protocol GDDRender;
@protocol GDCMessage;

@interface GDDTableViewDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

#pragma mark Read model

- (GDDModel *)modelForIndexPath:(NSIndexPath *)indexPath;

- (GDDModel *)modelForId:(NSString *)mid;
- (NSIndexPath*)indexPathForId:(NSString*)mid;

// Returns the model describing the section's header, or nil if there is no header.
- (GDDModel *)headerModelForSection:(NSInteger)section;

#pragma mark Change model

- (void)insertModels:(NSArray<GDDModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)clearModels;

@end

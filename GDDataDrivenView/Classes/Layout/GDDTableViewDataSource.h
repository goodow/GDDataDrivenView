//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>

@class GDDRenderModel;

@interface GDDTableViewDataSource : NSObject <UITableViewDataSource>

#pragma mark Read model

- (instancetype)initWithTopic:(NSString *)topic;

- (GDDRenderModel *)renderModelForIndexPath:(NSIndexPath *)indexPath;

- (GDDRenderModel *)renderModelForId:(NSString *)mid;
- (NSIndexPath*)indexPathForId:(NSString*)mid;

// Returns the model describing the section's header, or nil if there is no header.
- (GDDRenderModel *)headerRenderModelForSection:(NSInteger)section;

#pragma mark Change model
- (void)insertModels:(NSArray<GDDRenderModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)clearModels;

@end

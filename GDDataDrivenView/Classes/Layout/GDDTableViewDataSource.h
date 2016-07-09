//
//  Created by Larry Tin on 7/9/16.
//

#import <UIKit/UIKit.h>

@class GDDRenderModel;

@interface GDDTableViewDataSource : NSObject <UITableViewDataSource>

- (GDDRenderModel *)renderModelForIndexPath:(NSIndexPath *)indexPath;

- (GDDRenderModel *)renderModelForTopic:(NSString *)topic;
- (NSIndexPath*)indexPathForTopic:(NSString*)topic;

/// Returns the model describing the section's header, or nil if there is no header.
- (GDDRenderModel *)headerRenderModelForSection:(NSInteger)section;

@end

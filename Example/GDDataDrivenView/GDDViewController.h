//
//  Created by Larry Tin on 07/09/2016.
//

@import UIKit;

@class GDDRenderModel;

@interface GDDViewController : UITableViewController

@property NSString *topic;

- (void)appendToLastRow:(GDDRenderModel *)model;
@end

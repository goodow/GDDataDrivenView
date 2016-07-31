//
//  Created by Larry Tin on 07/09/2016.
//

@import UIKit;

@class GDDModel;

@interface GDDViewController : UITableViewController

@property NSString *topic;

- (void)appendToLastRow:(GDDModel *)model;
@end

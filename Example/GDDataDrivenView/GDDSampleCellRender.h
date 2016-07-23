//
//  Created by Larry Tin on 16/7/12.
//

#import <UIKit/UIKit.h>
#import <GDDataDrivenView/GDDRender.h>

@interface GDDSampleCellRender : UITableViewCell <GDDRender>
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property(nonatomic, copy) void (^tapHandler)();
@end

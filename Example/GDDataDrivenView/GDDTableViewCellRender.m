//
//  Created by Larry Tin on 16/7/12.
//

#import "GDDTableViewCellRender.h"

@interface GDDTableViewCellRender ()
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property(weak, nonatomic) IBOutlet UIImageView *contentImageView;
@end

@implementation GDDTableViewCellRender

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//  UIView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
////  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//  self = view;
//  if (self) {
////    [self.contentView addSubview:view];
//  }
//  return self;
//}

- (void)handleData:(NSDictionary *)data {
  self.titleLabel.text = data[@"title"];
  self.usernameLabel.text = data[@"username"];
  NSString *imageName = data[@"imageName"];
  self.contentImageView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;
}

@end

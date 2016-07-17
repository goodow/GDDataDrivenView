//
//  Created by Larry Tin on 16/7/12.
//

#import "GDDTableViewCellRender.h"

@interface GDDTableViewCellRender ()
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property(weak, nonatomic) IBOutlet UIImageView *contentImageView;
@end

@implementation GDDTableViewCellRender

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
  if (self) {
  }
  return self;
}

- (void)handleData:(NSDictionary *)data {
  static int a;
  a++;
  NSLog(@"handleData: %lu", a);
  self.titleLabel.text = data[@"title"];
  self.contentLabel.text = data[@"content"];
  self.usernameLabel.text = data[@"username"];
  self.timeLabel.text = data[@"time"];
  NSString *imageName = data[@"imageName"];
  self.contentImageView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;
}

// If you are not using auto layout, override this method, enable it by setting
// "fd_enforceFrameLayout" to YES.
- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat totalHeight = 0;
  totalHeight += [self.titleLabel sizeThatFits:size].height;
  totalHeight += [self.contentLabel sizeThatFits:size].height;
  totalHeight += [self.contentImageView sizeThatFits:size].height;
  totalHeight += [self.usernameLabel sizeThatFits:size].height;
  totalHeight += 40; // margins
  return CGSizeMake(size.width, totalHeight);
}
@end

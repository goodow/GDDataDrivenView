//
//  Created by Larry Tin on 16/7/12.
//

#import "GDDTableViewCellRender.h"
#import "GDCMessageImpl.h"

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

- (instancetype)init {
  self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
  if (self) {

  }

  return self;
}

//- (GDDTableViewCellRender *)initWithPayload:(GDDRenderModel *)model {
//    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
//    if (self) {
//        GDCMessageImpl *message = [[GDCMessageImpl alloc] init];
//        message.payload = model;
//        [self handleMessage:message];
//    }
//    return self;
//}


- (void)handleMessage:(id <GDCMessage>)message {
  GDDRenderModel *model = message.payload;
  NSDictionary *data = model.data;
  self.titleLabel.text = data[@"title"];
  self.usernameLabel.text = data[@"username"];
  NSString *imageName = data[@"imageName"];
  self.contentImageView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;
}


@end

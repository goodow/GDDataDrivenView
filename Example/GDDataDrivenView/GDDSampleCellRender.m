//
//  Created by Larry Tin on 16/7/12.
//

#import "GDDSampleCellRender.h"

@interface GDDSampleCellRender ()

@end

@implementation GDDSampleCellRender

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
  [self addEventHandler];

  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
  if (self) {
    [self addEventHandler];
  }
  NSLog(@"%s", __PRETTY_FUNCTION__);
  return self;
}

- (void)dealloc {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)addEventHandler {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  tapGesture.cancelsTouchesInView = NO;
  [self addGestureRecognizer:tapGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
  if (self.tapHandler) {
    self.tapHandler();
  }
}

// If you are not using auto layout, override this method, enable it by setting
// "fd_enforceFrameLayout" to YES.
- (CGSize)sizeThatFits:(CGSize)size {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  CGFloat totalHeight = 0;
  totalHeight += [self.titleLabel sizeThatFits:size].height;
  totalHeight += [self.contentLabel sizeThatFits:size].height;
  totalHeight += [self.contentImageView sizeThatFits:size].height;
  totalHeight += [self.usernameLabel sizeThatFits:size].height;
  totalHeight += 40; // margins
  return CGSizeMake(size.width, totalHeight);
}
@end

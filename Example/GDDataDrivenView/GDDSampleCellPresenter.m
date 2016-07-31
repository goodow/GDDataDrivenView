//
// Created by Larry Tin on 16/7/23.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDSampleCellPresenter.h"
#import "GDDSampleCellRender.h"
#import "GDDViewController.h"

@interface GDDSampleCellPresenter ()
@property(weak, nonatomic) GDDViewController *owner;
@end

@implementation GDDSampleCellPresenter {
}
- (instancetype)initWithOwner:(GDDViewController *)owner {
  _owner = owner;
  return [self init];
}

- (void)update:(GDDSampleCellRender *)render withModel:(GDDModel *)model {
  static int a;
  a++;
  NSLog(@"%s: %d", __PRETTY_FUNCTION__, a);

  NSDictionary *data = model.data;
  render.titleLabel.text = data[@"title"];
  render.contentLabel.text = data[@"content"];
  render.usernameLabel.text = data[@"username"];
  render.timeLabel.text = data[@"time"];
  NSString *imageName = data[@"imageName"];
  render.contentImageView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;

  __weak GDDSampleCellPresenter *weakSelf = self;
  render.tapHandler = ^{
      [weakSelf.owner appendToLastRow:model];
  };
}

@end
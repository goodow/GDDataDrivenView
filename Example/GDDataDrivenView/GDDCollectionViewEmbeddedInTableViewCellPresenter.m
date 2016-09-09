//
// Created by Larry Tin on 7/31/16.
// Copyright (c) 2016 Larry Tin. All rights reserved.
//

#import "GDDCollectionViewEmbeddedInTableViewCellPresenter.h"
#import "GDDCollectionViewEmbeddedInTableViewCellRender.h"
#import "GDDViewController.h"
#import "GDDCollectionViewLayout.h"
#import "GDDSampleCollectionViewCellRender.h"
#import "NSObject+GDChannel.h"
#import "GDDModel.h"

@interface GDDCollectionViewEmbeddedInTableViewCellPresenter ()
@property(nonatomic, weak) GDDViewController *owner;
@property(nonatomic, strong) GDDCollectionViewLayout *layout;
@end

@implementation GDDCollectionViewEmbeddedInTableViewCellPresenter {

}

- (instancetype)initWithOwner:(id)owner {
  _owner = owner;
  return [self init];
}

- (void)update:(GDDCollectionViewEmbeddedInTableViewCellRender *)render withData:(NSDictionary *)data {
  NSString *layoutTopic = [NSString stringWithFormat:@"%@/%@/%@", self.owner.topic, @"layouts", [[NSUUID alloc] init].UUIDString];
  self.layout = [[GDDCollectionViewLayout alloc] initWithCollectionView:
      render.collectionView withTopic:layoutTopic withOwner:self.owner];

  NSArray *images = data[@"images"];
  NSMutableArray<GDDModel *> *models = @[].mutableCopy;
  for (NSString *image in images) {
    [models addObject:[[GDDModel alloc] initWithData:image withId:nil
                            withNibNameOrRenderClass:NSStringFromClass(GDDSampleCollectionViewCellRender.class)]];
  }
  [self.bus publishLocal:[self.layout topicForSection:0] payload:models];
}

@end
//
// Created by Larry Tin on 7/31/16.
//

#import "GDDCollectionViewDelegate.h"
#import "GDDBaseViewDataSource.h"
#import "GDDCollectionViewDataSource.h"


@implementation GDDCollectionViewDelegate {
  __weak GDDCollectionViewDataSource *_dataSource;
}

- (instancetype)initWithDataSource:(GDDCollectionViewDataSource *)dataSource {
  self = [super init];
  if (self) {
    _dataSource = dataSource;
  }
  return self;
}

@end
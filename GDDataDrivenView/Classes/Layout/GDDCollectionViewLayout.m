//
// Created by Larry Tin on 7/24/16.
//

#import "GDDCollectionViewLayout.h"
#import "GDDCollectionViewDataSource.h"
#import "GDDCollectionViewDelegate.h"

@interface GDDCollectionViewLayout ()
@property(nonatomic) GDDCollectionViewDelegate *delegate;
@end

@implementation GDDCollectionViewLayout {
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView withTopic:(NSString *)layoutTopic withOwner:(id)owner {
  self = [super initWithTopic:layoutTopic withView:collectionView];
  if (self) {
    super.dataSource = [[GDDCollectionViewDataSource alloc] initWithCollectionView:collectionView withLayout:self withOwner:owner];
    _delegate = [[GDDCollectionViewDelegate alloc] initWithDataSource:super.dataSource];

    collectionView.dataSource = super.dataSource;
    collectionView.delegate = _delegate;
//    collectionView.showsHorizontalScrollIndicator = NO;

    UICollectionViewLayout *viewLayout = collectionView.collectionViewLayout;
    if ([viewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
      ((UICollectionViewFlowLayout *) viewLayout).estimatedItemSize = CGSizeMake(100, 100);
    }
  }
  return self;
}
@end
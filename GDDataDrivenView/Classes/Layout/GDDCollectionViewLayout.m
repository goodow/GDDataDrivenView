//
// Created by Larry Tin on 7/24/16.
//

#import <UIKit/UIKit.h>
#import "GDDCollectionViewLayout.h"

@interface GDDCollectionViewLayout ()
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation GDDCollectionViewLayout {

}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView withTopic:(NSString *)layoutTopic withOwnerView:(id)ownerView {
  self = [super init];
  if (self) {
    _collectionView = collectionView;
    UICollectionViewLayout *viewLayout = collectionView.collectionViewLayout;
    if ([viewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
      ((UICollectionViewFlowLayout *) viewLayout).estimatedItemSize = CGSizeMake(100, 100);
    }
  }
  return self;
}

@end
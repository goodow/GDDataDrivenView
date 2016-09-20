//
// Created by Larry Tin on 7/31/16.
//

#import <UIKit/UIKit.h>
#import "GDDBaseViewDataSource.h"

@class GDDCollectionViewLayout;

@interface GDDCollectionViewDataSource : GDDBaseViewDataSource <UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView withLayout:(GDDCollectionViewLayout *)layout withOwner:(id)owner;

@end
//
// Created by Larry Tin on 7/24/16.
//

#import <Foundation/Foundation.h>
#import "GDDBaseViewLayout.h"

@interface GDDCollectionViewLayout : GDDBaseViewLayout

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView withTopic:(NSString *)layoutTopic withOwner:(id)owner;

@end
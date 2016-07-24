//
// Created by Larry Tin on 7/24/16.
//

#import <Foundation/Foundation.h>

@class UICollectionView;


@interface GDDCollectionViewLayout : NSObject

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView withTopic:(NSString *)layoutTopic withOwnerView:(id)ownerView;

@end
//
// Created by Larry Tin on 7/31/16.
//

#import <Foundation/Foundation.h>

@class GDDCollectionViewDataSource;

@interface GDDCollectionViewDelegate : NSObject <UICollectionViewDelegateFlowLayout>
- (instancetype)initWithDataSource:(GDDCollectionViewDataSource *)source;
@end
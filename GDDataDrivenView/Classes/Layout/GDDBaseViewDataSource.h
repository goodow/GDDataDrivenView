//
//  Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>

@class GDDModel;
@protocol GDDRender;
@protocol GDDRenderPresenter;

@interface GDDBaseViewDataSource : NSObject

- (instancetype)initWithView:(id)view withOwner:(id)owner;

@property (nonatomic, weak) id view;

#pragma mark Read model

- (GDDModel *)modelForIndexPath:(NSIndexPath *)indexPath;

- (GDDModel *)modelForId:(NSString *)mid;
- (NSIndexPath *)indexPathForId:(NSString *)mid;

// Returns the model describing the section's header, or nil if there is no header.
- (GDDModel *)headerModelForSection:(NSInteger)section;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

#pragma mark Change model

- (void)insertModels:(NSArray<GDDModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)clearModels;

#pragma mark Display model

- (id <GDDRenderPresenter>)reloadModel:(GDDModel *)model forRender:(id <GDDRender>)render;
@end

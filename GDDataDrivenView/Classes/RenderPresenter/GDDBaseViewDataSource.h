//
//  Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>

@class GDDRenderModel;
@protocol GDDRender;
@protocol GDDRenderPresenter;

@interface GDDBaseViewDataSource : NSObject

- (instancetype)initWithView:(id)view withOwner:(id)owner;

@property (nonatomic, weak) id view;

#pragma mark Read model

- (GDDRenderModel *)modelForIndexPath:(NSIndexPath *)indexPath;

- (GDDRenderModel *)modelForId:(NSString *)mid;
- (NSIndexPath *)indexPathForId:(NSString *)mid;

// Returns the model describing the section's header, or nil if there is no header.
- (GDDRenderModel *)headerModelForSection:(NSInteger)section;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

#pragma mark Change model

- (void)insertModels:(NSArray<GDDRenderModel *> *)models atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

- (void)clearModels;

#pragma mark Display model

- (id <GDDRenderPresenter>)reloadModel:(GDDRenderModel *)model forRender:(id <GDDRender>)render;
@end

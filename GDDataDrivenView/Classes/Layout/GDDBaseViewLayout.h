//
// Created by Larry Tin on 7/31/16.
//

#import <Foundation/Foundation.h>

@class GDDModel;
@class GDDBaseViewDataSource;

@interface GDDBaseViewLayout : NSObject

@property(nonatomic, copy) void (^infiniteScrollingHandler)(NSArray<GDDModel *> *models, void (^loadComplete)(BOOL hasMore));

@property(nonatomic, readonly) NSString *modelsTopic;
@property(nonatomic, readonly) NSString *sectionsTopic;
@property(nonatomic) NSMutableArray<GDDModel *> *models;
@property(nonatomic) GDDBaseViewDataSource *dataSource;
@property(nonatomic, weak) UIScrollView *view;

- (instancetype)initWithTopic:(NSString *)layoutTopic withView:(id)view;

- (NSString *)topicForSection:(NSInteger)section;

- (void)setTopic:(NSString *)layoutTopic;
@end
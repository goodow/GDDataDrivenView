//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>


@interface GDDRenderModel : NSObject
@property(nonatomic, readonly) __kindof id data;
@property(nonatomic, readonly) NSString *mid;
@property(nonatomic, readonly) Class renderClass;
@property(nonatomic, weak) __kindof UIView *render;
@property(nonatomic, copy) void (^tapHandler)(GDDRenderModel *renderModel, UITapGestureRecognizer *sender);

- (instancetype)initWithData:(id)data withId:(NSString *)mid withRenderClass:(Class)renderClass;
@end
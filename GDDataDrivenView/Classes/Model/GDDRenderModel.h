//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>


@interface GDDRenderModel : NSObject
@property Class renderClass;
@property(nonatomic) __kindof id data;
@property(nonatomic) NSString *topic;
@property(nonatomic, weak) __kindof UIView *render;
@property(nonatomic, copy) void (^tapHandler)(GDDRenderModel *renderModel, UITapGestureRecognizer *sender);

@end
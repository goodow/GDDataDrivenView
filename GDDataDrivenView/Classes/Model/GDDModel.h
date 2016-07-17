//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDCSerializable.h"
#import "GDDRender.h"

@interface GDDModel : NSObject <GDCSerializable>
@property(nonatomic, readonly) __kindof id data;
@property(nonatomic, readonly) NSString *mid;
@property(nonatomic, readonly) NSString *renderType;

@property(nonatomic, weak) __kindof UIView <GDDRender> *render;
@property(nonatomic, copy) void (^tapHandler)(GDDModel *model, UITapGestureRecognizer *sender);

- (instancetype)initWithData:(id)data withId:(NSString *)mid withNibNameOrRenderClass:(NSString *)nibNameOrRenderClass;

- (void)reloadData;
@end
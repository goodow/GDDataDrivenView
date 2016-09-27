//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDCSerializable.h"
#import "GDDModel.h"

@interface GDDRenderModel : GDDModel <GDCSerializable>
@property(nonatomic, readonly) __kindof id <GDCSerializable> data;
@property(nonatomic, readonly) NSString *mid;
@property(nonatomic, readonly) NSString *renderType;

- (instancetype)initWithData:(id <GDCSerializable>)data withId:(NSString *)mid withNibNameOrRenderClass:(NSString *)nibNameOrRenderClass;

@end
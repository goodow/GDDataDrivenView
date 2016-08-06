//
// Created by Larry Tin on 7/9/16.
//

#import <Foundation/Foundation.h>
#import "GDCSerializable.h"

@interface GDDModel : NSObject <GDCSerializable>
@property(nonatomic, readonly) __kindof id <GDCSerializable> data;
@property(nonatomic, readonly) NSString *mid;
@property(nonatomic, readonly) NSString *renderType;

- (instancetype)initWithData:(id <GDCSerializable>)data withId:(NSString *)mid withNibNameOrRenderClass:(NSString *)nibNameOrRenderClass;

#if !(SelfSizing_UpdateConstraints)
//@property(nonatomic, weak) UIView *render;
#endif
@end
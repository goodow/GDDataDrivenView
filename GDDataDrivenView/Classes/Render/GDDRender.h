//
// Created by Larry Tin on 7/9/16.
//


#import <GDChannel/GDCMessageHandler.h>
#import "GDDRenderModel.h"

@protocol GDDRender <GDCMessageHandler>

@optional
- (instancetype)initWithPayload:(GDDRenderModel *)model;

@end
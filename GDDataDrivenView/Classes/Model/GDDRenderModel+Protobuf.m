//
// Created by Larry Tin on 16/7/14.
//

#import "GDDRenderModel+Protobuf.h"
#import "GPBMessage.h"
#import "GPBMessage+JsonFormat.h"

static NSString *const dataKey = @"data";
static NSString *const midKey = @"mid";
static NSString *const renderClassKey = @"renderClass";
static NSString *const dataClassKey = @"dataClass";

@implementation GDDRenderModel (Protobuf)

+ (instancetype)parseFromJson:(NSDictionary *)json error:(NSError **)errorPtr {
  Class renderClass = NSClassFromString(json[renderClassKey]);
  Class dataClass = NSClassFromString(json[dataClassKey]);
  id data = json[dataKey];
  if ([dataClass conformsToProtocol:@protocol(GDCSerializable)]) {
    NSError *error = nil;
    data = [dataClass parseFromJson:data error:&error];
  }
  NSString *mid = json[midKey];
  if (!mid) {
    mid = [[NSUUID alloc] init].UUIDString;
  }
  GDDRenderModel *model = [[self alloc] initWithData:data withId:mid withRenderClass:renderClass];
  return model;
}

- (NSDictionary *)toJson {
  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  json[dataKey] = ((id<GDCSerializable>)self.data).toJson;
  json[midKey] = self.mid;
  json[renderClassKey] = NSStringFromClass(self.renderClass);
  json[dataClassKey] = NSStringFromClass([self.data class]);
  return nil;
}

@end
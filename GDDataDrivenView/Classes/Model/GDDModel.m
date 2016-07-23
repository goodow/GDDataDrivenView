//
// Created by Larry Tin on 7/9/16.
//

#import "GDCSerializable.h"
#import "GDDModel.h"
#import "GPBMessage.h"

@implementation GDDModel {

}

- (instancetype)initWithData:(id)data withId:(NSString *)mid withNibNameOrRenderClass:(NSString *)nibNameOrRenderClass {
  self = [super init];
  if (self) {
    _data = data;
    _mid = mid ?: [[NSUUID alloc] init].UUIDString;
    _renderType = nibNameOrRenderClass;
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  GDDModel *copy = [[GDDModel allocWithZone:zone] initWithData:self.data withId:self.mid withNibNameOrRenderClass:self.renderType];
  return copy;
}

- (NSString *)description {
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.toJson
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark GDCSerializable
static NSString *const dataKey = @"data";
static NSString *const midKey = @"mid";
static NSString *const renderTypeKey = @"renderType";
static NSString *const dataTypeKey = @"@type";

+ (instancetype)parseFromJson:(NSDictionary *)json error:(NSError **)errorPtr {
  id data = json[dataKey];
  if ([data isKindOfClass:NSDictionary.class]) {
    NSString *typeUrl = data[dataTypeKey];
    Class dataClass = NSClassFromString(typeUrl.lastPathComponent);
    if ([dataClass conformsToProtocol:@protocol(GDCSerializable)]) {
      NSError *error = nil;
      data = [dataClass parseFromJson:data error:&error];
    }
  }
  NSString *mid = json[midKey] ?: [[NSUUID alloc] init].UUIDString;
  return [[self alloc] initWithData:data withId:mid withNibNameOrRenderClass:json[renderTypeKey]];
}

- (NSDictionary *)toJson {
  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  json[dataKey] = self.data.toJson.mutableCopy;
  if (![self.data isKindOfClass:NSMutableDictionary.class] && ![self.data isKindOfClass:NSMutableArray.class]) {
    json[dataKey][dataTypeKey] = [NSString stringWithFormat:@"://%@", NSStringFromClass([self.data class])];
  }
  json[midKey] = self.mid;
  json[renderTypeKey] = self.renderType;
  return json;
}

- (void)mergeFromJson:(NSDictionary *)json {
  id data = json[dataKey];
  [self.data mergeFromJson:data];
}

- (void)mergeFrom:(GDDModel *)other {
  [self.data mergeFrom:other.data];
}
@end
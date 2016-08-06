//
// Created by Larry Tin on 7/9/16.
//

#import "GDCSerializable.h"
#import "GDDModel.h"
#import "GPBAny+GDChannel.h"

@implementation GDDModel {

}

- (instancetype)initWithData:(id <GDCSerializable>)data withId:(NSString *)mid withNibNameOrRenderClass:(NSString *)nibNameOrRenderClass {
  self = [super init];
  if (self) {
    _data = data;
    _mid = mid ?: [[NSUUID alloc] init].UUIDString;
    _renderType = nibNameOrRenderClass;
  }

  return self;
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

+ (instancetype)parseFromJson:(NSDictionary *)json error:(NSError **)errorPtr {
  id data = [GPBAny unpackFromJson:json[dataKey] error:nil];
  NSString *mid = json[midKey];
  mid = mid.length > 0 ? mid : nil;
  return [[self alloc] initWithData:data withId:mid withNibNameOrRenderClass:json[renderTypeKey]];
}

- (NSDictionary *)toJson {
  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  if (self.data) {
    json[dataKey] = [GPBAny packToJson:self.data];
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
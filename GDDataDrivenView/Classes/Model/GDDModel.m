//
// Created by Larry Tin on 7/9/16.
//

#import "GDCSerializable.h"
#import "GDDModel.h"
#import "GDCStorage.h"
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
  copy.tapHandler = self.tapHandler;
  return copy;
}

#pragma mark Event Handler

- (void)handleTap:(UITapGestureRecognizer *)sender {
  if (self.tapHandler) {
    self.tapHandler(self, sender);
  }
}

- (void)reloadData {
  if ([self.render respondsToSelector:@selector(presenter)]) {
    [self.render.presenter handleData:self.data];
  } else {
    [self.render handleData:self.data];
  }
}

#pragma mark GDCSerializable
static NSString *const dataKey = @"data";
static NSString *const midKey = @"mid";
static NSString *const renderTypeKey = @"renderType";
static NSString *const dataTypeKey = @"dataType";

+ (instancetype)parseFromJson:(NSDictionary *)json error:(NSError **)errorPtr {
  id data = json[dataKey];
  Class dataClass = NSClassFromString(json[dataTypeKey]);
  if ([dataClass conformsToProtocol:@protocol(GDCSerializable)]) {
    NSError *error = nil;
    data = [dataClass parseFromJson:data error:&error];
  }
  NSString *mid = json[midKey] ?: [[NSUUID alloc] init].UUIDString;
  return [[self alloc] initWithData:data withId:mid withNibNameOrRenderClass:json[renderTypeKey]];
}

- (NSDictionary *)toJson {
  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  if ([self.data conformsToProtocol:@protocol(GDCSerializable)]) {
    json[dataKey] = ((id <GDCSerializable>) self.data).toJson;
    json[dataTypeKey] = NSStringFromClass([self.data class]);
  } else {
    json[dataKey] = self.data;
  }
  json[midKey] = self.mid;
  json[renderTypeKey] = self.renderType;
  return json;
}

- (void)mergeFromJson:(NSDictionary *)json {
  id data = json[dataKey];
  if ([self.data conformsToProtocol:@protocol(GDCSerializable)]) {
    [self.data mergeFromJson:data];
    return;
  }
  [GDCStorage patchJsonRecursively:self.data with:data];
}

- (void)mergeFrom:(GDDModel *)other {
  if ([self.data conformsToProtocol:@protocol(GDCSerializable)]) {
    if ([other.data conformsToProtocol:@protocol(GDCSerializable)]) {
      [self.data mergeFrom:other];
    } else {
      [self.data mergeFromJson:other.data];
    }
    return;
  }
  [GDCStorage patchJsonRecursively:self.data with:other.data];
}
@end
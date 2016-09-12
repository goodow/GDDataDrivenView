//
// Created by Larry Tin on 16/9/12.
//

#import "NSObject+GDDataDrivenView.h"
#import "Aspects.h"

@implementation NSObject (GDDataDrivenView)

- (void)subscribeLocalToSelf:(NSString *)topic, ... {
  NSMutableArray *consumers = @[].mutableCopy;
  id eachObject;
  va_list argumentList;
  if (topic) { // The first argument isn't part of the varargs list, so we'll handle it separately.
    [consumers addObject:[self subscribe:self toOne:topic]];
    va_start(argumentList, topic); // Start scanning for arguments after firstObject.
    while (eachObject = va_arg(argumentList, id)) { // As many times as we can get an argument of type "id"
      [consumers addObject:[self subscribe:self toOne:eachObject]]; // that isn't nil, add it to self's contents.
    }
    va_end(argumentList);

    [self aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^{
        for (id <GDCMessageConsumer> consumer in consumers) {
          [consumer unsubscribe];
        }
    } error:nil];
  }
}

- (id <GDCMessageConsumer>)subscribe:(NSObject <GDCMessageHandler> *)handler toOne:(NSString *)topic {
  return [self.bus subscribeLocal:topic handler:^(id <GDCMessage> message) {
      [handler handleMessage:message];
  }];
}
@end
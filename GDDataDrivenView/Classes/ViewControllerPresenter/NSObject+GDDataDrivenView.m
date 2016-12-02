//
// Created by Larry Tin on 16/9/12.
//

#import "NSObject+GDDataDrivenView.h"
#import "Aspects.h"

@implementation NSObject (GDDataDrivenView)

- (void)subscribeLocalToSelf:(NSArray<NSString *> *)topics {
  NSMutableArray *consumers = [NSMutableArray arrayWithCapacity:topics.count];
  for (NSString *topic in topics) {
    [consumers addObject:[self subscribe:self toOne:topic]];
  }
  [self aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
      for (id <GDCMessageConsumer> consumer in consumers) {
        [consumer unsubscribe];
      }
      [consumers removeAllObjects];
  } error:NULL];
}

- (id <GDCMessageConsumer>)subscribe:(NSObject <GDCMessageHandler> *)handler toOne:(NSString *)topic {
  __weak id <GDCMessageHandler> weakHandler = handler;
  return [self.bus subscribeLocal:topic handler:^(id <GDCMessage> message) {
      [weakHandler handleMessage:message];
  }];
}

@end
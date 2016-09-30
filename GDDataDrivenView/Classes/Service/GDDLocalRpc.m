#import "GDDLocalRpc.h"

@implementation GDDLocalRpc {
  id _result;
  NSError *_error;

  void (^_success)(id);

  void (^_failure)(NSError *);
}
- (GDDLocalRpc *(^)(id))result {
  return ^GDDLocalRpc *(id result) {
      _result = result;
      return self;
  };
}

- (GDDLocalRpc *(^)(NSError *error))error {
  return ^GDDLocalRpc *(NSError *error) {
      _error = error;
      return self;
  };
}

- (GDDLocalRpc *(^)(void (^success)(id response)))success {
  return ^GDDLocalRpc *(void (^success)(id)) {
      _success = success;
      return self;
  };
}

- (GDDLocalRpc *(^)(void (^failure)(NSError *)))failure {
  return ^GDDLocalRpc *(void (^failure)(NSError *)) {
      _failure = failure;
      return self;
  };
}

- (void)load {
  if (_error) {
    _failure ? _failure(_error) : nil;
    return;
  }

  _success ? _success(_result) : nil;
}

@end
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

- (nullable id<GDDTask>  (^)(id query))load {
  return ^ _Nullable id<GDDTask> (id query) {
      if (_error) {
        _failure ? _failure(_error) : nil;
        return nil;
      }

      _success ? _success(_result) : nil;
      return nil;
  };
}

@end
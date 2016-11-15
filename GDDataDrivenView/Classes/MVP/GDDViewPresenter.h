//
// Created by Larry Tin on 16/9/20.
//

#import <UIKit/UIKit.h>
#import "GDDPresenter.h"

@protocol GDDViewPresenter <GDDPresenter>

- (void)update:(UIView<GDDView> *)view withData:(id)data;

@optional
- (UIView *) view;

@end
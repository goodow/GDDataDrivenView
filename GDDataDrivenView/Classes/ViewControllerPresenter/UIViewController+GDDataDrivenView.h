#import <UIKit/UIKit.h>
#import "GoodowExtrasOption.pbobjc.h"
#import "GDDViewControllerTransition.h"

@interface UIViewController (GDDataDrivenView)

@property(nonatomic, readonly, nonnull) GDDPBViewOption *viewOption;

@end

@interface UIView (GDDataDrivenView)

@end

@interface GDDViewControllerTransition (GDDataDrivenView)

+ (void)aspect_hookSelector;

+ (UIViewController *)getVisibleChildViewController:(UIViewController *)parent;

@end

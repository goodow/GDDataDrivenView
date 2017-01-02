//
// Created by Larry Tin on 10/7/16.
//

#import <UIKit/UIKit.h>
#import "GoodowExtrasOption.pbobjc.h"
#import "GoodowBool.pbobjc.h"

@interface GDDPBViewOption (FluentInterface)

- (GDDPBViewOption *(^)(enum GDDPBLaunchMode launchMode))setLaunchMode;
- (GDDPBViewOption *(^)(enum GDDPBStackMode stackMode))setStackMode;

- (GDDPBViewOption *(^)(enum GDPBBool statusBar))setStatusBar;
- (GDDPBViewOption *(^)(enum GDPBBool navBar))setNavBar;
- (GDDPBViewOption *(^)(UIStatusBarStyle statusBarStyle))setStatusBarStyle;
- (GDDPBViewOption *(^)(UIBarStyle navBarStyle))setNavBarStyle;
- (GDDPBViewOption *(^)(BOOL hidesBottomBarWhenPushed))setHidesBottomBarWhenPushed;
- (GDDPBViewOption *(^)(enum GDPBBool tabBar))setTabBar;
- (GDDPBViewOption *(^)(UIInterfaceOrientationMask supportedInterfaceOrientations))setSupportedInterfaceOrientations;
- (GDDPBViewOption *(^)(enum GDPBBool autorotate))setAutorotate;

- (GDDPBViewOption *(^)(BOOL needsRefresh))setNeedsRefresh;
- (GDDPBViewOption *(^)(BOOL attemptRotationToDeviceOrientation))setAttemptRotationToDeviceOrientation;
- (GDDPBViewOption *(^)(UIDeviceOrientation deviceOrientation))setDeviceOrientation;
- (GDDPBViewOption *(^)(enum GDPBBool toolBar))setToolBar;

- (GDDPBViewOption *(^)(UIInterfaceOrientation preferredInterfaceOrientationForPresentation))setPreferredInterfaceOrientationForPresentation;
- (GDDPBViewOption *(^)(UIModalPresentationStyle modalPresentationStyle))setModalPresentationStyle;
- (GDDPBViewOption *(^)(UIModalTransitionStyle modalTransitionStyle))setModalTransitionStyle;
- (GDDPBViewOption *(^)(UIRectEdge edgesForExtendedLayout))setEdgesForExtendedLayout;
@end
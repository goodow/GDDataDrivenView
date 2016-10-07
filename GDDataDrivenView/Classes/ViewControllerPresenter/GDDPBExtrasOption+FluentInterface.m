//
// Created by Larry Tin on 10/7/16.
//

#import "GDDPBExtrasOption+FluentInterface.h"

#define kImplementMethodChaining(name) \
- (GDDPBViewOption *(^)(int name))set##name { \
    return ^GDDPBViewOption *(int name) { \
        self.name = name; \
        return self; \
    }; \
}

@implementation GDDPBViewOption (FluentInterface)

kImplementMethodChaining(LaunchMode);
kImplementMethodChaining(StackMode);

kImplementMethodChaining(StatusBar);
kImplementMethodChaining(NavBar);
kImplementMethodChaining(StatusBarStyle);
kImplementMethodChaining(NavBarStyle);
kImplementMethodChaining(HidesBottomBarWhenPushed);
kImplementMethodChaining(TabBar);
kImplementMethodChaining(SupportedInterfaceOrientations);
kImplementMethodChaining(Autorotate);

kImplementMethodChaining(NeedsRefresh);
kImplementMethodChaining(AttemptRotationToDeviceOrientation);
kImplementMethodChaining(DeviceOrientation);
kImplementMethodChaining(ToolBar);

kImplementMethodChaining(PreferredInterfaceOrientationForPresentation);
kImplementMethodChaining(ModalPresentationStyle);
kImplementMethodChaining(ModalTransitionStyle);
kImplementMethodChaining(EdgesForExtendedLayout);

@end
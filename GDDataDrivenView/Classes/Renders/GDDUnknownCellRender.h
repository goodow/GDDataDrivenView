//
// Created by Larry Tin on 16/8/9.
//

#import <Foundation/Foundation.h>
#import "GDDRender.h"

@interface GDDUnknownCellRender : UITableViewCell <GDDRender, GDDPresenter>

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
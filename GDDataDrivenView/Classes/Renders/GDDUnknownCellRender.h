//
// Created by Larry Tin on 16/8/9.
//

#import <Foundation/Foundation.h>
#import "GDDRender.h"
#import "GDDRenderPresenter.h"

@interface GDDUnknownCellRender : UITableViewCell <GDDRender, GDDRenderPresenter>

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
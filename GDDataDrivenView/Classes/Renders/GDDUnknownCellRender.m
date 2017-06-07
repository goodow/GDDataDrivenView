//
// Created by Larry Tin on 16/8/9.
//

#import <objc/runtime.h>
#import "GDDUnknownCellRender.h"
#import "UITableViewCell+GDDRender.h"

static const char kExpandHeightKey = 0;

@interface GDDUnknownCellRender ()
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) id data;
@end

@implementation GDDUnknownCellRender {
//  BOOL _didSetupConstraints;
  NSLayoutConstraint *_heightConstraint;
  NSLayoutConstraint *_pinBottomToSuperviewConstraint;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_descriptionLabel];

    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];

    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"H:|-0-[view]-0-|"                                                  options:0 metrics:nil views:@{@"view" : _descriptionLabel}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
        @"V:|-0-[view]"                                                      options:0 metrics:nil views:@{@"view" : _descriptionLabel}]];

    _heightConstraint = [NSLayoutConstraint constraintWithItem:_descriptionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    _pinBottomToSuperviewConstraint = [NSLayoutConstraint constraintWithItem:_descriptionLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

    [self addEventHandler];
  }

  return self;
}

- (void)update:(GDDUnknownCellRender *)render withData:(id)data {
  self.descriptionLabel.text = [data description];

  self.data = data;
  BOOL expand = [objc_getAssociatedObject(data, &kExpandHeightKey) boolValue];
  if (expand) {
    [self.descriptionLabel removeConstraint:_heightConstraint];
    [self.contentView addConstraint:_pinBottomToSuperviewConstraint];
  } else {
    [self.contentView removeConstraint:_pinBottomToSuperviewConstraint];
    // 高度约束会引发如下警告, _pinBottomToSuperviewConstraint就不会
    // Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead.
    [self.descriptionLabel addConstraint:_heightConstraint];
  }
}

//- (void)updateConstraints {
//  if (!_didSetupConstraints) {
//    // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
//    // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
//    //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//    // self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
//    _didSetupConstraints = YES;
//  }
//
//  [super updateConstraints];
//}

- (void)addEventHandler {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  [self addGestureRecognizer:tapGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
  BOOL expand = [objc_getAssociatedObject(self.data, &kExpandHeightKey) boolValue];
  objc_setAssociatedObject(self.data, &kExpandHeightKey, @(!expand), OBJC_ASSOCIATION_ASSIGN);

  UITableView *tableView = [self nearestTableView];
  [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForCell:self]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (id <GDDRenderPresenter>)presenter {
  return self;
}

@end
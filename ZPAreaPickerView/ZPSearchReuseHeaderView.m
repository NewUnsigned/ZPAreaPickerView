//
//  SLSearchReuseHeaderView.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ZPSearchReuseHeaderView.h"
#import "VBFPopFlatButton.h"
#import "CALayer+SLPopAddition.h"
#import "UIView+Extension.h"
#import "UIView+Extension.h"

@interface ZPSearchReuseHeaderView ()

@property (weak, nonatomic) VBFPopFlatButton *arrowButton;
@property (weak, nonatomic) UIButton *titleBtn;

@end

@implementation ZPSearchReuseHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        if (_arrowButton == nil) {
            [self commentInit];
        }
    }
    return self;
}

- (void)commentInit{
    CGRect btnFrame = CGRectMake(0, 0, 20, 20);
    VBFPopFlatButton *arrowButton = [[VBFPopFlatButton alloc]initWithFrame:btnFrame buttonType:buttonDownBasicType buttonStyle:buttonPlainStyle animateToInitialState:YES];
    arrowButton.tintColor = [UIColor whiteColor];
    arrowButton.lineThickness = 1;
    _arrowButton = arrowButton;
    [self addSubview:arrowButton];
    
    UIButton *titleBtn = [[UIButton alloc]init];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _titleBtn = titleBtn;
    [titleBtn addTarget:self action:@selector(viewButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleBtn];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _arrowButton.frame = CGRectMake(self.width - 50, (self.height - 20) * 0.5, 20, 20);
    _titleBtn.frame    = CGRectMake(30, 0, self.width - 70, self.height);
}

- (void)viewButtonDidClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(reuseView:didClickedTitleButton:)]) {
        [self.delegate reuseView:self didClickedTitleButton:_arrowButton];
    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
    [_titleBtn setTitle:title forState:UIControlStateNormal];
}

- (void)setIndex:(NSUInteger)index{
    _index = index;
    _arrowButton.tag = index;
}

- (void)setIsUp:(BOOL)isUp{
    _isUp = isUp;
    FlatButtonType type = isUp ? buttonUpBasicType : buttonDownBasicType;
    [_arrowButton animateToType:type];
}

@end

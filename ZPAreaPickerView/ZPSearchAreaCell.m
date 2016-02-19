//
//  SLSearchAreaCell.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ZPSearchAreaCell.h"
#import "UIView+Extension.h"

@interface ZPSearchAreaCell ()

@property (weak, nonatomic) UILabel *cellTitle;
@property (weak, nonatomic) UIView *line;

@end

@implementation ZPSearchAreaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *title = [[UILabel alloc]init];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor whiteColor];
        [self addSubview:title];
        _cellTitle = title;
        title.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [[UIColor colorWithRed:242/255.0 green:246/255.0 blue:248/255.0 alpha:1] colorWithAlphaComponent:0.3];
        _line = line;
        [self addSubview:line];
    }
    return self;
}

- (void)layoutSubviews{
    _cellTitle.frame = CGRectMake(0, 0, self.width, self.height);
    _line.frame = CGRectMake(0, self.height - 1, self.width, 1);
}

- (void)setCityItem:(ZPSearchCityItem *)cityItem{
    _cityItem = cityItem;
    _cellTitle.text = _cityItem.cityName;
}

@end

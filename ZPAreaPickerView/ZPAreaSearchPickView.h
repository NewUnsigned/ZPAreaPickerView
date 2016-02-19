//
//  SLSearchCityPickView.h
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CitySelectValueBlock)(NSString *country,NSString *city);

@interface ZPAreaSearchPickView : UIView
@property (copy, nonatomic) CitySelectValueBlock selectBlock;

+ (instancetype)cityPickViewWithFrame:(CGRect)frame title:(NSString *)title;

@end

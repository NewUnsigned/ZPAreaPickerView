//
//  SLSearchReuseHeaderView.h
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol ZPSearchReuseHeaderViewDelegate;

@interface ZPSearchReuseHeaderView : UITableViewHeaderFooterView
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL isUp;
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) id<ZPSearchReuseHeaderViewDelegate> delegate;

@end

@protocol ZPSearchReuseHeaderViewDelegate <NSObject>

- (void)reuseView:(ZPSearchReuseHeaderView *)view didClickedTitleButton:(UIButton *)btn;

@end
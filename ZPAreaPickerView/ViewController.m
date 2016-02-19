//
//  ViewController.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ViewController.h"
#import "ZPAreaSearchPickView.h"
#import "UIView+Extension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZPAreaSearchPickView *pick = [ZPAreaSearchPickView cityPickViewWithFrame:CGRectMake(0, 100, self.view.width, 88) title:@"区域选择"];
    
    [self.view addSubview:pick];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

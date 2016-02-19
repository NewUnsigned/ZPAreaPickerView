//
//  SLSearchAreaItem.h
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPSearchAreaItem : NSObject
/*
*  是否展开
*/
@property (assign, nonatomic,getter=isFold) BOOL fold;

@property (copy, nonatomic) NSString *country;

/**
 *  存放city的数据模型数组
 */
@property (strong, nonatomic) NSArray *cityArray;

@property (assign, nonatomic) NSUInteger index;

@property (assign, nonatomic) BOOL isHot;

@property (copy, nonatomic) NSString *countryId;

@property (copy, nonatomic) NSString *name;

+ (instancetype)areaItemWithDictionary:(NSDictionary *)dict;
+ (NSArray *)countryItemsWithDictionaries:(NSArray *)dicts;

-(NSComparisonResult)compareModel:(ZPSearchAreaItem *)model;

@end

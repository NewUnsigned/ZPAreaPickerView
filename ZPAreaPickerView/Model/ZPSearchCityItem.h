//
//  SLSearchCityItem.h
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPSearchCityItem : NSObject <NSCopying>

@property (copy, nonatomic) NSString *cityName;
@property (assign, nonatomic) NSUInteger index;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, assign) BOOL isHot;

+ (instancetype)cityItemWithDictionary:(NSDictionary *)dict;
+ (NSArray *)cityItemsWithDictionaries:(NSArray *)dicts;


-(NSComparisonResult)compareModel:(ZPSearchCityItem *)model;

@end

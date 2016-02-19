//
//  SLSearchCityItem.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ZPSearchCityItem.h"

@implementation ZPSearchCityItem

- (id)copyWithZone:(NSZone *)zone{
    ZPSearchCityItem *item = [[ZPSearchCityItem alloc]init];
    item.cityName = self.cityName;
    item.index    = self.index;
    return item;
}

-(NSComparisonResult)compareModel:(ZPSearchCityItem *)model
{
    return [[NSNumber numberWithInteger:self.index] compare:[NSNumber numberWithInteger:model.index]];
}

+ (instancetype)cityItemWithDictionary:(NSDictionary *)dict {
    ZPSearchCityItem *item = [[self alloc] init];
    item.cityId   = dict[@"kCityId"];
    item.cityName = dict[@"kName"];
    item.isHot    = [dict[@"kIsHot"] boolValue];
    
    return item;
}

+ (NSArray *)cityItemsWithDictionaries:(NSArray *)dicts {
    if (![dicts isKindOfClass:[NSArray class]] || dicts.count == 0) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:dicts.count];
    [dicts enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        ZPSearchCityItem *item = [self cityItemWithDictionary:dict];
        item.index = idx;
        [items addObject:item];
    }];
    
    return [items copy];
}

@end

//
//  SLSearchAreaItem.m
//  ZPAreaPickerView
//
//  Created by 赵鹏 on 16/2/18.
//  Copyright © 2016年 赵鹏. All rights reserved.
//

#import "ZPSearchAreaItem.h"

@implementation ZPSearchAreaItem
-(NSComparisonResult)compareModel:(ZPSearchAreaItem *)model
{
    model.fold = NO;
    return [[NSNumber numberWithInteger:self.index] compare:[NSNumber numberWithInteger:model.index]];
}

+ (instancetype)areaItemWithDictionary:(NSDictionary *)dict{
    ZPSearchAreaItem *item  = [[ZPSearchAreaItem alloc]init];
    item.country   = dict[@"kName"];
    item.isHot     = [dict[@"kIsHot"] boolValue];
    item.countryId = dict[@"kCountryId"];
    return item;
}

+ (NSArray *)countryItemsWithDictionaries:(NSArray *)dicts {
    if (![dicts isKindOfClass:[NSArray class]] || dicts.count == 0) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:dicts.count];
    [dicts enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        ZPSearchAreaItem *item = [self areaItemWithDictionary:dict];
        item.index = idx;
        [items addObject:item];
    }];
    
    return [items copy];
}

@end

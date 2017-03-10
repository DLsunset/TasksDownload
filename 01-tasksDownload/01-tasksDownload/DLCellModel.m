//
//  DLCellModel.m
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/9.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import "DLCellModel.h"

@implementation DLCellModel

+ (instancetype) modelWithDict:(NSDictionary *)dict {
    
    DLCellModel *model = [[DLCellModel alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}

@end

//
//  DLCellModel.h
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/9.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLCellModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *progress;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, assign) NSString *speed;


+ (instancetype) modelWithDict:(NSDictionary *)dict;

@end

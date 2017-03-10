//
//  DLTableViewCell.h
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/8.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLCellModel.h"
@class DLTableViewCell;
@protocol DLTableViewCellDelegate <NSObject>

- (void)downloadOrPauseTaskWithCell:(DLTableViewCell *)cell;

@end

@interface DLTableViewCell : UITableViewCell

@property(nonatomic, strong) DLCellModel *model;
@property(nonatomic, weak) id <DLTableViewCellDelegate> delegate;
@property(nonatomic, strong) UILabel *speedLabel;
@end

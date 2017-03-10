//
//  DLTableViewCell.m
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/8.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import "DLTableViewCell.h"
#import "Masonry.h"

@interface DLTableViewCell ()

@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UIProgressView *progress;
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, assign) int i;

@end

@implementation DLTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _i = 0;
    
    _name = [[UILabel alloc] init];
    _name.text = @"文件名";
    _name.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_name];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(10);
        make.width.offset(300);
    }];
    
    _progress = [[UIProgressView alloc] init];
    _progress.progress = 0.5;
    [self.contentView addSubview:_progress];
    [_progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.bottom.offset(-10);
        make.width.offset(300);
    }];
    
    _progressLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_progressLabel];
    _progressLabel.font = [UIFont systemFontOfSize:10];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_name);
        make.top.equalTo(_name.mas_bottom).offset(7);
        make.width.offset(60);
    }];
    
    _speedLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_speedLabel];
    _speedLabel.textAlignment = NSTextAlignmentRight;
    _speedLabel.font = [UIFont systemFontOfSize:10];
    [_speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_progress);
        make.top.equalTo(_name.mas_bottom).offset(7);
        make.width.offset(100);
    }];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btn setImage:[UIImage imageNamed:@"pause_1418px_1183436_easyicon.net"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"download_158px_1205413_easyicon.net"] forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(downloadClick:) forControlEvents:UIControlEventTouchUpInside];
    self.accessoryView = btn;
}

- (void)downloadClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.model.isSelected = sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(downloadOrPauseTaskWithCell:)]) {
        [self.delegate downloadOrPauseTaskWithCell:self];
    }

}

- (void)setModel:(DLCellModel *)model {
    _model = model;
    self.name.text = model.name;
    self.progress.progress = model.progress.floatValue;
    UIButton *btn = (UIButton *)self.accessoryView;
    btn.selected = model.isSelected;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",model.progress.floatValue * 100];

    //这个if是为了降低speedlabel的刷新速率
    if (_i % 5 == 0) {
        //根据速度大小,显示不同样式
        if (model.speed.floatValue >= 1048576) {
            self.speedLabel.text = [NSString stringWithFormat:@"%.2fMB/s",model.speed.floatValue / 1048576];
        }else {
            self.speedLabel.text = [NSString stringWithFormat:@"%.1fKB/s",model.speed.floatValue / 1024];
        }
    }
    
    if (_i == 100) {
        _i = 0;
    }
    _i++;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

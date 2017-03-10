//
//  ViewController.m
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/8.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import "ViewController.h"
#import "DLTableViewCell.h"
#import "DLDownLoadManager.h"
#import "DLCellModel.h"


@interface ViewController ()<UITableViewDataSource,DLTableViewCellDelegate,UITableViewDelegate,UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (weak, nonatomic) IBOutlet UITableView *taskList;
@property (nonatomic, strong) NSMutableArray *arrUrls;
@property (nonatomic, strong) NSMutableArray *modelArr;
@property (nonatomic, strong) UIDocumentInteractionController *docIc;
@property (nonatomic, copy) NSString *savepath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskList.dataSource = self;
    self.taskList.delegate = self;
    _arrUrls = [[NSMutableArray alloc] init];
    _modelArr = [[NSMutableArray alloc] init];
    [self.taskList registerClass:[DLTableViewCell class] forCellReuseIdentifier:@"cellid"];
//    _docIc = [[UIDocumentInteractionController alloc] init];
}

/*
 测试用链接:
 http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.1.dmg  QQ
 https://dldir1.qq.com/music/clntupate/mac/QQMusic4.2.3Build02.dmg  QQ音乐
 http://s1.music.126.net/download/osx/NeteaseMusic_1.5.1_530_web.dmg  网易云音乐
 http://dzs.qisuu.com/txt/%E4%BB%96%E4%BB%8E%E7%81%AB%E5%85%89%E4%B8%AD%E8%B5%B0%E6%9D%A5.txt 小说
 */



- (IBAction)DownLoadClick:(id)sender {
    
    //记录地址文本框的内容,便于开始下载后移除文本框的内容,而此地址不至于丢失
    NSString *path = self.urlText.text;
    
    //创建根据地址文本框中的地址下载任务
    [[DLDownLoadManager sharedManager] downloadWithUrlStr:self.urlText.text andProgressBlock:^(float progress, NSString *name, float speed) {
        
//        NSLog(@"进度:%f",progress);
        //根据回调的进度,文件名,下载速度,创建字典,为了给cell重新赋值,刷新数据
        NSDictionary *dict = @{@"name":name, @"progress":@(progress) ,@"path":path,@"speed":@(speed)};
        //将字典转换成模型,方便给cell赋值
        DLCellModel *model = [DLCellModel modelWithDict:dict];
        
        //因为需要在每次添加新任务时需要多出一个cell,因此必须刷新tableView,但这段代码正在不停的回调,不能一直刷新tableView,因此,判断之前是否有新任务出现.判断的依据是_arrurls数组中有没有同名的元素,如果没有,就添加进去,并且给模型数组添加一个元素,然后刷新tableView,这样便会多出一个新cell,也就是新任务
        if (![_arrUrls containsObject:name]) {
            [_arrUrls addObject:name];
            [self.modelArr addObject:model];
            [self.taskList reloadData];
        }
        //根据_arrUrls中的元素数量来确定cell的indexpath.因为此处拿不到cell,所以不能通过cell获取角标.因为在新添加任务的时候,可以确定新任务会在哪个cell上,所以这样获取角标不会有问题.应该不会有问题吧...起码测试上没问题
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:_arrUrls.count - 1 inSection:0];
        //通过不断赋值新的model来更新cell上的数据
        ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexpath]).model = model;
        //为了保证在新添加任务的时候会刷新tableView,而此时数组模型中前面的cell的model还都是最初始的数据,所以新添加任务会重置前面的cell,为了保证之前的任务的model数据不会受影响,因此需要时刻通过替换模型数组中的旧model.
         [self.modelArr replaceObjectAtIndex:indexpath.row withObject:((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexpath]).model];
    } withCompletionBolck:^(NSString *savePath) {
        NSLog(@"下载完成!");
        //下载完成后再更新一次模型数组中的model,不过貌似不需要
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:_arrUrls.count - 1 inSection:0];
        [self.modelArr replaceObjectAtIndex:indexpath.row withObject:((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexpath]).model];
        
        //创建一个新的button,替换原来的下载暂停按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [btn setImage:[UIImage imageNamed:@"success_500px_1201384_easyicon.net"] forState:UIControlStateNormal];
        UIImageView *completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_500px_1201384_easyicon.net"]];
        completedView.frame = CGRectMake(0, 0, 25, 25);
        ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexpath]).accessoryView = btn;
        //下载完成后将速度label清空
        ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexpath]).speedLabel.text = nil;
    }];
    //点击完下载按钮,创建完新任务,地址文本框中的数据需要清除
    self.urlText.text = nil;
   [self.taskList reloadData];
}


//下面的方法是在点击了暂停按钮后会走的方法,而点击过暂停按钮后,block的回调就会走这个方法里面的block,而不再走上面方法中的block了.
- (void)downloadOrPauseTaskWithCell:(DLTableViewCell *)cell {
    
    DLCellModel *model = cell.model;
    NSString *url = model.path;
    
    NSIndexPath *indexPath = [self.taskList indexPathForCell:cell];
    
    if ([[DLDownLoadManager sharedManager] checkisDownloadingWithUrl:url]) {
        [[DLDownLoadManager sharedManager] pauseDownloadWithUrl:url];
    }else {
        [[DLDownLoadManager sharedManager] downloadWithUrlStr:url andProgressBlock:^(float progress, NSString *name, float speed) {
            NSLog(@"进度:%f",progress);
            NSDictionary *dict = @{@"name":name, @"progress":@(progress) ,@"path":url,@"speed":@(speed)};
            DLCellModel *model = [DLCellModel modelWithDict:dict];
            
            if (![_arrUrls containsObject:name]) {
                [_arrUrls addObject:name];
                [self.modelArr addObject:model];
                [self.taskList reloadData];
            }
            
            ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexPath]).model = model;
             [self.modelArr replaceObjectAtIndex:indexPath.row withObject:((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexPath]).model];
        } withCompletionBolck:^(NSString *savePath) {
            NSLog(@"下载完成!");
            [self.modelArr replaceObjectAtIndex:indexPath.row withObject:((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexPath]).model];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
            [btn setImage:[UIImage imageNamed:@"success_500px_1201384_easyicon.net"] forState:UIControlStateNormal];
            UIImageView *completedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_500px_1201384_easyicon.net"]];
            completedView.frame = CGRectMake(0, 0, 25, 25);
            ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexPath]).accessoryView = btn;
            ((DLTableViewCell *)[self.taskList cellForRowAtIndexPath:indexPath]).speedLabel.text = nil;
        }];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelArr.count;
}

- (DLTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    
    cell.model = _modelArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

//下面几个方法是删除cell用的,做的还不完善,不知道有没有隐藏bug
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.modelArr removeObjectAtIndex:indexPath.row];
    [self.arrUrls removeObjectAtIndex:indexPath.row];
    [self.taskList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

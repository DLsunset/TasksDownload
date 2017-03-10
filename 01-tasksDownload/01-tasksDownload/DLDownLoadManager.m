//
//  DLDownLoadManager.m
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/8.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import "DLDownLoadManager.h"

@interface DLDownLoadManager ()<NSURLSessionDownloadDelegate>

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSMutableDictionary *progressDict;
@property(nonatomic, strong) NSMutableDictionary *downloadTaskDict;
@property(nonatomic, strong) NSMutableDictionary *completionDict;
@property(nonatomic, strong) NSDate *date;
@end


@implementation DLDownLoadManager

+ (instancetype)sharedManager {
    
    static DLDownLoadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DLDownLoadManager alloc] init];
    });
    return manager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        self.progressDict = [[NSMutableDictionary alloc] init];
        self.downloadTaskDict = [[NSMutableDictionary alloc] init];
        self.completionDict = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void)downloadWithUrlStr:(NSString *)urlStr andProgressBlock:(void(^)(float progress, NSString *name, float speed))progressBlock withCompletionBolck:(void(^)(NSString *savePath))completionBlock{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *saveResumeDataPath = [NSString stringWithFormat:@"/Users/donglei/Desktop/%@.data",urlStr.lastPathComponent];
    NSData *resumeData = [NSData dataWithContentsOfFile:saveResumeDataPath];
    
    NSURLSessionDownloadTask *downLoadTask;
    
    if (resumeData) {
        downLoadTask = [self.urlSession downloadTaskWithResumeData:resumeData];
        
        [[NSFileManager defaultManager] removeItemAtPath:saveResumeDataPath error:nil];
        
    }else {
        downLoadTask = [self.urlSession downloadTaskWithURL:url];
    }
    
    [self.progressDict setObject:progressBlock forKey:downLoadTask];
    [self.downloadTaskDict setObject:downLoadTask forKey:urlStr];
    [self.completionDict setObject:completionBlock forKey:downLoadTask];
    [downLoadTask resume];
    NSLog(@"progressDict :%@ \n downloadTaskDict:%@\ncompletionDict :%@",self.progressDict,self.downloadTaskDict,self.completionDict);
}

- (BOOL)checkisDownloadingWithUrl:(NSString *)url {
    
    if ([self.downloadTaskDict objectForKey:url]) {
        return YES;
    }
    return NO;
}

- (void)pauseDownloadWithUrl:(NSString *)urlStr {
    
    NSURLSessionDownloadTask *downloadTask = [self.downloadTaskDict objectForKey:urlStr];
    
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        NSString *resumePath = [NSString stringWithFormat:@"/Users/donglei/Desktop/%@.data",urlStr.lastPathComponent];
        [resumeData writeToFile:resumePath atomically:YES];
        
        [self.progressDict removeObjectForKey:downloadTask];
        [self.completionDict removeObjectForKey:downloadTask];
        [self.downloadTaskDict removeObjectForKey:urlStr];
    }];
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *savePath = [NSString stringWithFormat:@"/Users/donglei/Desktop/%@", downloadTask.response.suggestedFilename];
    NSLog(@"文件保存路径:%@",savePath);
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:savePath] error:nil];
    
    void (^completionBlock)(NSString *savePath) = [self.completionDict objectForKey:downloadTask];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (completionBlock) {
            completionBlock(savePath);
        }
    }];
    
    [self.completionDict removeObjectForKey:downloadTask];
    [self.downloadTaskDict removeObjectForKey:downloadTask.currentRequest.URL.absoluteString];
    [self.progressDict removeObjectForKey:downloadTask];
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
//    NSLog(@"didWriteData:%lld",bytesWritten);
    
    //根据下载的数据和所用的时间,计算出下载速度,并用block回调回去
    float speed = [self getDownloadSpeed:bytesWritten];

    void(^progressBlock)(float progress, NSString *name,float speed) = [self.progressDict objectForKey:downloadTask];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (progressBlock) {
            progressBlock(progress,downloadTask.response.suggestedFilename,speed);
        }
    }];
    
}

//这个方法没有用,是获取沙盒路径的
- (NSString *)getDocumentPath {
    
    NSString *homePath = NSHomeDirectory();
    
        //2.3获取documents的路径
    NSString *docunmentPath = [homePath stringByAppendingString:@"/Documents"];
    
        //无需操心 到底有没有 斜杠
    NSString *docuPath = [homePath stringByAppendingPathComponent:@"Documents"];
    
    NSString *CachePath = [homePath stringByAppendingString:@"/Library/Caches"];
    
    NSLog(@"%@-%@",docuPath,docunmentPath);
    
    return CachePath;
}

//计算下载速度
- (float) getDownloadSpeed:(int64_t)bytesWritten {
    
    NSDate *dateNow = [NSDate date];
    NSTimeInterval time = [dateNow timeIntervalSinceDate:_date];
//    NSLog(@"%f",[dateNow timeIntervalSinceDate:_date]);
    _date = dateNow;
    
    return bytesWritten /time;

    
}


@end

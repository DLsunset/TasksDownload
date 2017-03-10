//
//  DLDownLoadManager.h
//  01-tasksDownload
//
//  Created by 董雷 on 2017/3/8.
//  Copyright © 2017年 董雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDownLoadManager : NSObject

- (void)downloadWithUrlStr:(NSString *)urlStr andProgressBlock:(void(^)(float progress, NSString *name, float speed))progressBlock withCompletionBolck:(void(^)(NSString *savePath))completionBlock;
+ (instancetype)sharedManager;

- (BOOL)checkisDownloadingWithUrl:(NSString *)url;
- (void)pauseDownloadWithUrl:(NSString *)urlStr;

@end

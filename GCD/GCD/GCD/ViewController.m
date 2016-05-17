//
//  ViewController.m
//  GCD
//
//  Created by 焦相如 on 5/13/16.
//  Copyright © 2016 jaxer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 同步
//    dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
//    
//    // 异步
//    dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
//    
//    dispatch_barrier_async(<#dispatch_queue_t queue#>, <#^(void)block#>)
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//    });
    

    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 获得全局并发队列
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 穿行队列
    dispatch_queue_t queue3 = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue3 = dispatch_queue_create("queue", NULL); //穿行队列
    
    dispatch_queue_t qu = dispatch_get_main_queue();
    
    NSLog(@"queue0 - %@", qu);
    NSLog(@"queue1 - %@", queue);
    NSLog(@"queue2 - %@", queue2);
    NSLog(@"queue3 - %@", queue3);

    // 从子线程回到主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 执行耗时的异步操作
        dispatch_async(dispatch_get_main_queue(), ^{
           // 回到主线程，执行 UI 刷新操作
        });
    });
    
    //延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //2秒后执行这里的代码...
    });

    // 使用dispatch_apply函数能进行快速迭代遍历
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index){
        // 执行10次代码，index顺序不确定
        NSLog(@"index--%lu", index);
    });
    
    dispatch_group_async(<#dispatch_group_t group#>, <#dispatch_queue_t queue#>, <#^(void)block#>)
}

/** 串行队列 */
- (void)serialQueue {
    
}

@end

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
    
//    [self testOther];
    
//    [self sync];
//    [self async];
    
//    [self dispatchOnce];
//    [self dispatchApply];
//    [self dispatchAfter];
    
//    [self dispatchGroup];
//    [self dispatchBarrier];
    [self dispatchSemaphore];

    // 从子线程回到主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 执行耗时的异步操作
        dispatch_async(dispatch_get_main_queue(), ^{
           // 回到主线程，执行 UI 刷新操作
        });
    });
}

/** 测试一些基本方法 */
- (void)testOther {
    // 获取主队列
    dispatch_queue_t main = dispatch_get_main_queue();
    
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 创建串行队列
    dispatch_queue_t queue2 = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("queue", NULL); //串行队列
    
    // 获得全局并发队列
    dispatch_queue_t queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"queue0 - %@", main);
    NSLog(@"queue1 - %@", queue);
    NSLog(@"queue2 - %@", queue2);
    NSLog(@"queue3 - %@", queue3);
}

/** 同步执行方法 */
- (void)sync {
//    dispatch_sync(dispatch_queue queue, dispatch_block_t block); //方法名
    
    // 创建一个并发队列，并同步执行
    dispatch_queue_t syncQueue = dispatch_queue_create("syncQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(syncQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3");
    });
    NSLog(@"4");
    
    // 创建一个串行队列，并同步执行
    dispatch_queue_t syncQueue2 = dispatch_queue_create("syncQueue2", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(syncQueue2, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3");
    });
    NSLog(@"4");
}

/** 异步执行方法 */
- (void)async {
//    dispatch_async(dispatch_queue_t queue, dispatch_block_t block); //方法名
    
    // 创建一个并发队列，异步执行
    dispatch_queue_t asyncQueue = dispatch_queue_create("myAsyncQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(asyncQueue, ^{
        NSLog(@"2");
        
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3");
    });
    NSLog(@"4");
    
    // 创建一个串行队列，异步执行
    dispatch_queue_t asyncQueue2 = dispatch_queue_create("myAsyncQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(asyncQueue2, ^{
        NSLog(@"2");
        
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3");
    });
    NSLog(@"4");
}

/** 一次性执行某个操作，并在应用生命周期内仅执行一次 */
- (void)dispatchOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"这里的代码只会执行一次");
    });
}

/** 延时执行 */
- (void)dispatchAfter {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //延时2秒后执行这里的代码...
        NSLog(@"延迟2秒后执行的代码……");
    });
}

/** 线程组 */
- (void)dispatchGroup {
    //线程组，是一种同步机制，可以让某些线程先执行，某些线程最后执行，以控制线程的执行顺序。
    // 分别异步执行2个耗时的操作、2个异步操作都执行完毕后，再回到主线程执行操作
    
    __block int i;
    __block int j;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        i = 1;
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        j = 2;
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%d", i+j);
        // 等前面的异步操作都执行完毕后，回到主线程...
    });
}

/** dispatch_apply 循环执行 */
- (void)dispatchApply {
    // 使用 dispatch_apply 函数能进行快速迭代遍历
    
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index){
        NSLog(@"index--%lu", index); // 代码执行10次，index顺序不确定
    });
}

/** 信号量 */
- (void)dispatchSemaphore {
//    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        NSLog(@"John");
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"Snow");
//        dispatch_semaphore_signal(sema);
//    });
    
//    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
//    for (int i=0; i<10; i++) {
//        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
//
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"%d", i);
//            dispatch_semaphore_signal(lock);
//        });
//    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
}

/** 同一个线程中的不同任务实现同步 */
- (void)dispatchBarrier {
    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"1");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"2");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"3");
    });
    
    // PS:像是在这里竖起一堵墙，把前后的执行隔开
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"4");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"5");
    });
}

@end

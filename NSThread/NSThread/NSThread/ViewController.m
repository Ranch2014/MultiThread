//
//  ViewController.m
//  NSThread
//
//  Created by 焦相如 on 5/13/16.
//  Copyright © 2016 jaxer. All rights reserved.
//

#import "ViewController.h"
#import "MyThread.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前线程
    NSThread *currentThread = [NSThread currentThread];
    NSLog(@"current thread is: %@", currentThread);
//    NSLog(@"current is main:%d", [currentThread isMainThread]?YES:NO);
    
//    //获取主线程
//    NSThread *mainThread = [NSThread mainThread];
//    NSLog(@"mainThread: %@", mainThread);
    
    
//    [self startThread];
//    [self runInBackground];
//    [self performSelector];
    [self testMyThread];
    
//    //创建线程后自动启动线程
//    [NSThread detachNewThreadSelector:@selector(run2)
//                             toTarget:self
//                           withObject:nil];
}

/** 测试自定义 NSThread 子类 */
- (void)testMyThread {
    MyThread *mythread = [[MyThread alloc] init];
    NSLog(@"is main:%d", [mythread isMainThread]?YES:NO);
    [mythread start];
}

/** 子线程进行耗时操作，主线程更新 UI */
- (void)performSelector {
    NSThread *subThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(run3)
                                                    object:nil];
    [subThread start];
}

/** 后台运行的线程 */
- (void)runInBackground {
    [self performSelectorInBackground:@selector(run2) withObject:self];
}

/** 初始化并启动一个线程，以及基本设置 */
- (void)startThread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(run)
                                                 object:nil];
    //设置线程名字
    thread.name = @"我的新线程";
    
    // 设置线程的优先级 (0.0-1.0)
    thread.qualityOfService = 1.0;
//    thread.threadPriority = 1.0; //已废弃
    
    //启动线程 (线程一启动,就会在线程 thread 中执行 self 的 run 方法)
    [thread start];
}

- (void)run {
    NSLog(@"线程开始执行");
    
    NSThread *current = [NSThread currentThread];
    NSLog(@"当前线程是：%@", current);
    
    // 线程休眠，可以模拟耗时操作
    [NSThread sleepForTimeInterval:2];
    
    NSThread *mainThread = [NSThread mainThread];
    NSLog(@"子线程中获取主线程 %@", mainThread); //??为何日志显示name=(null)??
    NSLog(@"---%@", mainThread.threadDictionary);
    NSLog(@"线程优先级---%f", mainThread.threadPriority);
}

- (void)run2 {
    @autoreleasepool {
        NSLog(@"%@ ,主线程：%@, 当前线程：%@", NSStringFromSelector(_cmd), [NSThread mainThread], [NSThread currentThread]);
    }
}

/** 子线程耗时操作 */
- (void)run3 {
//    NSLog(@"%@ 执行了", NSStringFromSelector(_cmd));
    NSLog(@"主线程：%@, 当前线程：%@", [NSThread mainThread], [NSThread currentThread]);
    NSLog(@"这里进行耗时操作……");
    
    [self performSelectorOnMainThread:@selector(invokeMain)
                           withObject:self
                        waitUntilDone:YES];
}

- (void)invokeMain {
    NSLog(@"主线程：%@, 当前线程：%@", [NSThread mainThread], [NSThread currentThread]);
    NSLog(@"回到主线程, 更新 UI");
}

@end

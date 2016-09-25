//
//  ViewController.m
//  NSOperation
//
//  Created by 焦相如 on 5/18/16.
//  Copyright © 2016 jaxer. All rights reserved.
//

#import "ViewController.h"
#import "MyOperation.h"

@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *queue; /**< NSOperationQueue 队列 */
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取主队列 (添加到主队列的操作，最终都在主线程执行)
    NSLog(@"mainQueue--%@", [NSOperationQueue mainQueue]);
    
    // 获取当前操作所在的队列
    NSLog(@"mainQueue--%@", [NSOperationQueue currentQueue]);

    [self initQueue];
    [self testThread];
//    [self testInvocation];
//    [self testBlockOperation];
    [self downloadImage];
}

/**
 *  初始化队列
 */
- (void)initQueue {
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.name = @"队列的名字"; //队列名字
    self.queue.maxConcurrentOperationCount = 3; //队列的最大并发数
}

/**
 *  NSInvocationOperation 子类
 */
- (void)testInvocation {
    /**
     封装操作 (各个参数含义)
     第一个：目标对象
     第二个：该操作要调用的方法
     第三个：调用方法传递的参数，若不接收参数，传 nil
     */
    NSInvocationOperation *inOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                              selector:@selector(run)
                                                                                object:nil];
//    [inOperation start]; //启动操作 (主线程执行)
    
    NSInvocationOperation *inOperation2 = [[NSInvocationOperation alloc] initWithTarget:self
                                                                              selector:@selector(run)
                                                                                object:nil];
    NSInvocationOperation *inOperation3 = [[NSInvocationOperation alloc] initWithTarget:self
                                                                              selector:@selector(run)
                                                                                object:nil];
    [self.queue addOperation:inOperation]; //不同的子线程中执行
    [self.queue addOperation:inOperation2];
    [self.queue addOperation:inOperation3];
}

- (void)run {
    NSLog(@"NSInvocationOperation--%@", [NSThread currentThread]);
}

/**
 *  NSBlockOperation 子类
 */
- (void)testBlockOperation {
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程中执行
        NSLog(@"NSBlockOperation_1--%@", [NSThread currentThread]);
    }];
    
    /**
     *  追加操作，通过 addExecutionBlock 方法添加更多的操作，追加的操作在子线程中执行。
     *  注意：只要 NSBlockOperation 封装的操作数 > 1，就会异步执行操作
     */
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation_2--%@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation_3--%@", [NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation_4--%@", [NSThread currentThread]);
    }];
    
    [blockOperation start];
}

/**
 *  自定义的 NSOperation 子类
 *  测试线程的开始和持续时间 (线程开始的时间是不确定的，并且持续时间也是不一定的)
 */
- (void)testThread {
    MyOperation *operation1 = [[MyOperation alloc] init];
    operation1.operationID = 1;
    [operation1 setQueuePriority:NSOperationQueuePriorityVeryLow]; //设置操作的优先级
//    [self.queue addOperation:operation1];
    
    MyOperation *operation2 = [[MyOperation alloc] init];
    operation2.operationID = 2;
    [operation2 setQueuePriority:NSOperationQueuePriorityVeryHigh];
    
//    [operation2 addDependency:operation1]; //设置操作之间的依赖
    
    [self.queue addOperation:operation1]; //添加到队列
    [self.queue addOperation:operation2];
    
    NSArray *operationArray = [self.queue operations]; //查看队列中的所有任务
    NSLog(@"queue 中的所有操作：%@", operationArray);
}

/** 开启子线程请求网络图片 */
- (void)downloadImage {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 303, 438)];
    [self.view addSubview:self.imageView];
    
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"下载队列";
    
    //直接使用 block 代码块作为 operation
    [downloadQueue addOperationWithBlock:^{
        NSURL *url = [[NSURL alloc] initWithString:@"https://img1.doubanio.com/lpic/s2768378.jpg"];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        NSLog(@"下载图片：%@", [NSThread currentThread]);
        
        // 在主界面更新 UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = [UIImage imageWithData:data];
            NSLog(@"刷新 UI: %@", [NSThread currentThread]);
        }];
    }];
}

@end

#GCD

- 全称是 `Grand Central Dispatch`, “伟大的中枢调度器”
- GCD是苹果公司为多核的并行运算提出的解决方案
- 纯C语言，提供了非常多强大的函数

##优势
1. GCD会自动利用更多的CPU内核（比如双核、四核）
2. GCD会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
3. 只需要告诉GCD想要执行什么任务，不需要编写任何线程管理代码

##基本概念
GCD中有2个核心概念：  
1. 任务：执行什么操作  
2. 队列：用来存放任务

```
// 1.定制任务:确定想做的事情
// 2.将任务添加到队列中:GCD会自动将队列中的任务取出，放到对应的线程中执行。
Tips：任务的取出遵循队列的FIFO原则：先进先出，后进后出
```

###任务
####一、执行任务

``` Objective-C
- queue: 队列
- block: 任务

// 1.用同步的方式执行任务
dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);

// 2.用异步的方式执行任务
dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

// 3.GCD 中还有个用来执行任务的函数
// 在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
```
注意：  
1. 同步：只能在当前线程中执行任务，不具备开启新线程的能力  
2. 异步：可以在新的线程中执行任务，具备开启新线程的能力  

###队列
####一、并发队列（Concurrent Dispatch Queue）
- 可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）
- 并发功能只有在异步（dispatch_async）函数下才有效

``` Objective-C
// 使用 dispatch_queue_create 函数创建队列 (参数：队列名称，队列的类型)
dispatch_queue_t dispatch_queue_create(const char *label, dispatch_queue_attr_t attr); 

// 创建并发队列 (示例代码)
dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);

// 使用 dispatch_get_global_queue 函数获得全局的并发队列
dispatch_queue_t dispatch_get_global_queue(long identifier, unsigned long flags);
/* 参数: dispatch_queue_priority_t priority (队列的优先级)
		unsigned long flags (此参数暂时无用，用0即可)
 */

// 示例代码
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

// 3.全局并发队列的优先级
#define DISPATCH_QUEUE_PRIORITY_HIGH 2 // 高
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0 // 默认（中）
#define DISPATCH_QUEUE_PRIORITY_LOW (-2) // 低
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN // 后台
```

####二、串行队列（Serial Dispatch Queue）
- 让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）

```
// 使用 dispatch_queue_create 函数创建串行队列（队列类型传递NULL或者DISPATCH_QUEUE_SERIAL）
dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);

// 使用 dispatch_get_main_queue() 获得主队列
dispatch_queue_t queue = dispatch_get_main_queue();
```
注意：主队列是GCD自带的一种特殊的串行队列，放在主队列中的任务，都会放到主线程中执行。

####三、各种队列的执行效果

![](http://upload-images.jianshu.io/upload_images/718760-c940a7f854626235.png)

特别注意：使用 sync 函数往当前串行队列中添加任务，会卡住当前的串行队列 (线程卡死)

##新手易混淆
>有4个术语比较容易混淆：同步、异步、并发、串行  

1.同步和异步主要影响：能不能开启新的线程

- 同步：只是在当前线程中执行任务，不具备开启新线程的能力
- 异步：可以在新的线程中执行任务，具备开启新线程的能力

2.并发和串行主要影响：任务的执行方式  

- 并发：多个任务并发（同时）执行
- 串行：一个任务执行完毕后，再执行下一个任务

##GCD 运用
###一、线程间通信

``` Objective-C
	// 从子线程回到主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 执行耗时的异步操作
        dispatch_async(dispatch_get_main_queue(), ^{
           // 回到主线程，执行 UI 刷新操作
        });
    });
```

###二、延时操作

``` Objective-C
	//延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //2秒后执行这里的代码...
    });
```

###三、一次性代码

``` Objective-C
	// 使用 dispatch_once 函数能保证某段代码在程序运行过程中只被执行1次
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// 只执行1次的代码(这里面默认是线程安全的)    
	});
```

###四、快速迭代

``` Objective-C
	// 使用dispatch_apply函数能进行快速迭代遍历
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index){
        // 执行10次代码，index 顺序不确定
    });
```

###五、队列组

``` Objective-C
// 分别异步执行2个耗时的操作、2个异步操作都执行完毕后，再回到主线程执行操作
dispatch_group_t group =  dispatch_group_create();

dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});

dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步操作都执行完毕后，回到主线程...
});
```



非原创，原文请移步 [iOS 多线程（二）GCD](http://www.jianshu.com/p/be70bd238af0)
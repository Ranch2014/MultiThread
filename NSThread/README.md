#NSThread

创建线程：

``` Objective-C
// 创建线程
NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];

// 启动线程 (线程一启动，就会在线程 thread 中执行 self 的 run 方法)
[thread start];

// 创建线程后自动启动线程
[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];

// 创建后台进程并启动
[self performSelectorInBackground:@selector(run) withObject:nil];
```

主线程相关方法：

``` Objective-C
// 返回主线程
+ (NSThread *)mainThread;

// 是否为主线程(类方法)
+ (BOOL)isMainThread; 

// 是否为主线程（对象方法）
- (BOOL)isMainThread;
```

线程间通信常用方法：

``` Objective-C
// 在主线程上执行操作
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;

// 在指定线程上执行操作
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait;
```

其他方法：

``` Objective-C
// 获取主线程
NSThread *current = [NSThread mainThread];

// 获取当前线程
NSThread *current = [NSThread currentThread];

// 线程休眠，可以模拟耗时操作
[NSThread sleepForTimeInterval:2];
```


参考：  

[http://www.jianshu.com/p/b8b6d073b5f9](http://www.jianshu.com/p/b8b6d073b5f9)

[http://blog.csdn.net/chenyufeng1991/article/details/51348770](http://blog.csdn.net/chenyufeng1991/article/details/51348770)
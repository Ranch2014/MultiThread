##NSOperation 简介
NSOperation 就是一个操作，准确的说就是一个任务，也相当于一个函数块、block块。然后，任务便会有开始执行(start), 取消(cancel), 是否取消(isCancel), 是否完成(isFinishing), 暂停(pause)等状态函数。

###特点

- 父类是 NSObject
- NSOperation 是 OC 语言中基于 GCD 的面向对象的封装。本质上是多 GCD 的封装，相比之下 GCD 更快一些。  
- NSOperation 拥有更多的函数可用。
- 使用起来比 GCD 更加简单。
- 苹果推荐使用，使用 NSOperation 不用关心线程以及线程的生命周期问题。
- NSOperation 是抽象类，不具备封装操作的能力，因此必须使用其子类。
- 在GCD中，任务用块（block）来表示，而块是个轻量级的数据结构；而操作队列中的『操作』NSOperation 则是个更加重量级的 OC 对象。

##NSOperationQueue

###NSOperationQueue 简介
NSOperation 可以调用 start 方法来执行任务，但默认是同步执行的。  
如果将 NSOperation 添加到 NSOperationQueue（操作队列）中，系统会自动异步执行 NSOperationQueue 中的操作。

``` Objective-C
// 将 NSOperation 对象添加操作到 NSOperationQueue 的方法
- (void)addOperation:(NSOperation *)op;
- (void)addOperationWithBlock:(void (^)(void))block;
```

###特点
- NSOperationQueue 可以方便的调用 cancel 方法来取消某个操作，而 GCD 中的任务是无法被取消的（安排好任务之后就不管了）。
- NSOperationQueue 中，可以建立各个 NSOperation 之间的依赖关系。
- NSOperationQueue 支持 KVO。可以监测 operation 是否正在执行（isExecuted）、是否结束（isFinished），是否取消（isCancelled）
- NSOperation 可以方便的指定操作优先级。
- 通过自定义 NSOperation 的子类可以实现操作重用。
- GCD 只支持 FIFO 的队列，而 NSOperationQueue 可以调整队列的执行顺序

###NSOperationQueue 中的两种队列
- 主队列  
	通过 mainQueue 获得，凡是放到主队列中的任务都将在主线程执行
- 非主队列  
	直接 alloc init 出来的队列。非主队列同时具备了并发和串行的功能，通过设置最大并发数属性来控制任务是并发执行还是串行执行。具备新开线程能力



##NSOperation 使用
- 使用 NSOperation 子类的方式有3种：

		1. NSInvocationOperation 子类
		2. NSBlockOperation 子类
		3. 自定义子类继承 NSOperation，并实现内部相应的方法

###1. NSInvocationOperation 子类

``` Objective-C
// 初始化 NSInvocationOperation 对象
- (id)initWithTarget:(id)target selector:(SEL)sel object:(id)arg;

// 调用 start 方法开始执行操作 (一旦执行操作，就会调用 target 的 sel 方法)
- (void)start;
```
注意：

- 默认情况下，调用了 start 方法后不会开新线程去执行操作，而是在当前线程同步执行操作。
- 只有将 NSOperation 放到一个 NSOperationQueue 中，才会异步执行操作。

###2. NSBlockOperation 子类

``` Objective-C
// 1.创建 NSBlockOperation 对象
+ (id)blockOperationWithBlock:(void (^)(void))block;

// 2.通过 addExecutionBlock: 方法添加更多的操作
- (void)addExecutionBlock:(void (^)(void))block;
```
注意：

- 只要 NSBlockOperation 封装的操作数大于1，就会异步执行操作。

###3. 自定义 NSOperation 子类

``` Objective-C
// 创建对象继承 NSOperation，重写 main 方法，在里面实现要执行的操作
- (void)main；
```
注意：

- 自己创建自动释放池（因为如果是异步操作，无法访问主线程的自动释放池）
- 经常通过 `- (BOOL)isCancelled` 方法方法检测操作是否被取消，对取消做出响应。


##多线程实现
配合使用 NSOperation 和 NSOperationQueue 实现多线程编程的步骤：
>1. 将需要执行的操作封装到 NSOperation 对象中
>2. 将 NSOperation 对象添加到 NSOperationQueue
>3. 系统会自动将 NSOperationQueue 中的 NSOperation 取出来，封装到新的线程中执行 (开多少线程由系统管理)

##其他方法

###1. 最大并发数
NSOperationQueue 可以通过对最大并发数设置，控制程序中线程的数量

``` Objective-C
// 最大并发数的相关方法
- (NSInteger)maxConcurrentOperationCount;
- (void)setMaxConcurrentOperationCount:(NSInteger)cnt;
```
###2. 取消/暂停/恢复

``` Objective-C
// 1.取消队列的所有操作
- (void)cancelAllOperations;
// 2.取消单个操作
- (void)cancel

// 暂停/恢复队列
- (void)setSuspended:(BOOL)b; // YES代表暂停队列，NO代表恢复队列
- (BOOL)isSuspended;
```
###3. 依赖
NSOperation 之间可以设置依赖来保证执行顺序。

``` Objective-C
// 添加依赖的方法
- (void)addDependency:(NSOperation *)op;

// 例如，若要让操作A执行完后，再执行操作B (操作B依赖于操作A)，可以这么写：
[operationB addDependency:operationA];

// 取消依赖的方法
- (void)removeDependency:(NSOperation *)op;
```
注意：可以在不同 queue 的 NSOperation 之间创建依赖关系。

###4. 操作的监听

``` Objective-C
// 可以监听一个操作的执行完毕
- (void (^)(void))completionBlock;
- (void)setCompletionBlock:(void (^)(void))block;
```



参考：  
[http://www.jianshu.com/p/c40067a51d96](http://www.jianshu.com/p/c40067a51d96)  
[http://www.jianshu.com/p/73f3ade4fb3f](http://www.jianshu.com/p/73f3ade4fb3f)  
[http://blog.csdn.net/chenyufeng1991/article/details/50281515](http://blog.csdn.net/chenyufeng1991/article/details/50281515)  
[http://www.jianshu.com/p/72a5c434dbce](http://www.jianshu.com/p/72a5c434dbce)  
官方文档
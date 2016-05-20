//
//  MyOperation.m
//  NSOperation
//
//  Created by 焦相如 on 5/18/16.
//  Copyright © 2016 jaxer. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation

- (void)main {
    @autoreleasepool {
//        NSLog(@"MyOperation--%@", [NSThread currentThread]);
        NSLog(@"MyOperation %i--开始", self.operationID);
        [NSThread sleepForTimeInterval:3];
        NSLog(@"MyOperation %i--结束", self.operationID);
    }
}

@end

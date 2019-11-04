//
//  ZrTimer.m
//  ZcTimer
//
//  Created by apple on 2019/11/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ZrTimer.h"

@implementation ZrTimer

static NSMutableDictionary *timers_;
static dispatch_semaphore_t semaphore_;
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (NSString *)execTask:(void(^)(void))task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
                repeat:(BOOL)repeat
                  asyn:(BOOL)async{
    if(!task || start<=0 ||(interval<=0&&repeat)) return nil;
    dispatch_queue_t queue = async?dispatch_queue_create(0, 0):dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, start * NSEC_PER_SEC, interval * NSEC_PER_SEC);
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    NSString *name = [NSString stringWithFormat:@"%lu",(unsigned long)timers_.count];
    timers_[name] = timer;
    dispatch_semaphore_signal(semaphore_);
    
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeat) {
            [self cancelTask:name];
        }
    });
    dispatch_resume(timer);
    
    return name;
}

+ (NSString *)execTask:(id)target
              selector:(SEL)selector
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
                repeat:(BOOL)repeat
                  asyn:(BOOL)async{
    if (!target || !selector) return nil;
    return [self execTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    } start:start interval:interval repeat:repeat asyn:async];
}
+ (void)cancelTask:(NSString *)name{
    if (name.length == 0) return;
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers_[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:name];
    }
    dispatch_semaphore_signal(semaphore_);
}

@end

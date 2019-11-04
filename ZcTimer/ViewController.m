//
//  ViewController.m
//  ZcTimer
//
//  Created by apple on 2019/11/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import "ZrTimer.h"

@interface ViewController ()
@property(nonatomic, copy) NSString *task;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.task = [ZrTimer execTask:^{
        NSLog(@"123");
    } start:2 interval:1 repeat:YES asyn:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [ZrTimer cancelTask:self.task];
}

@end

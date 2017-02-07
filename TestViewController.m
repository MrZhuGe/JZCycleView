//
//  TestViewController.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "TestViewController.h"
#import "JZCycleView.h"

@interface TestViewController () <JZCycleViewDelegate>

@property (nonatomic, strong) JZCycleView *cycleView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: 初始化
- (void)initView {
    
    self.cycleView = [[JZCycleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9/16)];
    self.cycleView.delegate = self;
    self.cycleView.backgroundColor = [UIColor orangeColor];
    self.cycleView.imageURL = @[@"http://192.168.0.13:4869/d6871a1e92feeee5af48ccdace3ec073?f=JPEG",
                                @"http://192.168.0.13:4869/fc944996bdcd27e15c630f727025bff8?f=JPEG"];
    [self.view addSubview:self.cycleView];
}

// MARK: JZCycleViewDelegate
- (void)jzCycleView:(JZCycleView *)cycleView clickIndex:(NSInteger)index {
    
    NSLog(@"clickIndex: %ld", index);
}

@end

//
//  ViewController.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "JZCCycleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    
    [self initView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: 初始化
- (void)initView {
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 40, 30);
    [rightBtn setTitle:@"测试" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onRightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    JZCCycleView *cycleView = [[JZCCycleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9/16)];
    cycleView.pageIndicatorTintColor = [UIColor lightGrayColor];
    cycleView.currentPageindicatorTintColor = [UIColor yellowColor];
    cycleView.timeInterval = 5.0f;
    [self.view addSubview:cycleView];
    
    NSArray *imageURL = @[@"http://192.168.0.13:4869/d6871a1e92feeee5af48ccdace3ec073?f=JPEG",
                          @"http://192.168.0.13:4869/fc944996bdcd27e15c630f727025bff8?f=JPEG",
                          @"http://192.168.0.13:4869/76f2628ef714fb1c207f126841f390bd?f=JPEG"];
    NSArray *valueHides = @[@YES, @YES, @NO];
    
    [cycleView addImagePaths:imageURL valueHides:valueHides];
    [cycleView addSysTime:@"1485326914" startTime:@"1485236220" endTime:@"1485495480"];
}

// MARK: 点击事件
- (void)onRightBtnClicked:(UIButton *)button {
    
    TestViewController *testVC = [[TestViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
}

@end

//
//  JZCycleView.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "JZCycleView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JZCycleView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *scrollView;

@property (nonatomic, strong) UIImageView   *leftIV;

@property (nonatomic, strong) UIImageView   *centerIV;

@property (nonatomic, strong) UIImageView   *rightIV;

@property (nonatomic, strong) NSTimer       *jzTimer;

@property (nonatomic, assign) NSInteger     leftIndex;

@property (nonatomic, assign) NSInteger     centerIndex;

@property (nonatomic, assign) NSInteger     rightIndex;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation JZCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
     
        [self initConfig];
        [self initView];
    }
    return self;
}

// MARK: 配置
- (void)initConfig {
    
    self.timeInterval = 2.0f;
}

// MARK: 初始化
- (void)initView {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
    [self addSubview:self.scrollView];
    
    self.leftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.leftIV.backgroundColor = [UIColor blueColor];
    [self.scrollView addSubview:self.leftIV];
    
    self.centerIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.centerIV.backgroundColor = [UIColor purpleColor];
    self.centerIV.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.centerIV];
    
    self.rightIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    self.rightIV.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:self.rightIV];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(15, self.scrollView.frame.size.height - 37, self.scrollView.frame.size.width - 30, 37)];
    self.pageControl.enabled = NO;
    [self addSubview:self.pageControl];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGRClicked)];
    [self.centerIV addGestureRecognizer:tapGR];
}

// MARK: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x == 0) {
        
        self.leftIndex = self.leftIndex - 1;
        self.centerIndex = self.centerIndex - 1;
        self.rightIndex = self.rightIndex - 1;
        
        if (self.leftIndex == -1) {
            self.leftIndex = self.imageURL.count - 1;
        }
        
        if (self.centerIndex == -1) {
            self.centerIndex = self.imageURL.count - 1;
        }
        
        if (self.rightIndex == -1) {
            self.rightIndex = self.imageURL.count - 1;
        }
    } else if (scrollView.contentOffset.x == scrollView.frame.size.width * 2) {
        
        self.leftIndex = self.leftIndex + 1;
        self.centerIndex = self.centerIndex + 1;
        self.rightIndex = self.rightIndex + 1;
        
        if (self.leftIndex == self.imageURL.count) {
            self.leftIndex = 0;
        }
        if (self.centerIndex == self.imageURL.count) {
            self.centerIndex = 0;
        }
        if (self.rightIndex == self.imageURL.count) {
            self.rightIndex = 0;
        }
    } else {
        return;
    }
    
    [self.leftIV sd_setImageWithURL:[NSURL URLWithString:self.imageURL[self.leftIndex]]];
    [self.centerIV sd_setImageWithURL:[NSURL URLWithString:self.imageURL[self.centerIndex]]];
    [self.rightIV sd_setImageWithURL:[NSURL URLWithString:self.imageURL[self.rightIndex]]];
    
    self.pageControl.currentPage = self.centerIndex;
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
}

// 非系统操作时，取消定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.jzTimer invalidate];
    self.jzTimer = nil;
}

// 非系统操作时，重启定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.jzTimer) {
        [self.jzTimer invalidate];
        self.jzTimer = nil;
        [self initJZTimer];
    } else {
        [self initJZTimer];
    }
}

// MARK: 设置定时器
- (void)initJZTimer {
    
    self.jzTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(onJZTimerClicked:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.jzTimer forMode:NSRunLoopCommonModes];
}

// MARK: 定时器响应事件
- (void)onJZTimerClicked:(NSTimer *)timer {
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, 0) animated:YES];
}

// MARK: 手势
- (void)onTapGRClicked {
    
    if ([self.delegate respondsToSelector:@selector(jzCycleView:clickIndex:)]) {
        [self.delegate jzCycleView:self clickIndex:self.centerIndex];
    }
}

// MARK: Setter
- (void)setImageURL:(NSArray *)imageURL {
    _imageURL = imageURL;
    
    if (imageURL.count == 0) {
        return;
    }
    
    self.leftIndex = imageURL.count - 1;
    self.centerIndex = 0;
    self.rightIndex = 1;
    
    if (imageURL.count == 1) {
        
        self.scrollView.scrollEnabled = NO;
        self.rightIndex = 0;
    }
    
    self.pageControl.numberOfPages = imageURL.count;
    
    [self.leftIV sd_setImageWithURL:[NSURL URLWithString:imageURL[self.leftIndex]]];
    [self.centerIV sd_setImageWithURL:[NSURL URLWithString:imageURL[self.centerIndex]]];
    [self.rightIV sd_setImageWithURL:[NSURL URLWithString:imageURL[self.rightIndex]]];
    
    // 启动定时器
    if (imageURL.count > 1) {
        if (self.jzTimer) {
            [self.jzTimer invalidate];
            self.jzTimer = nil;
            [self initJZTimer];
        } else {
            [self initJZTimer];
        }
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageindicatorTintColor:(UIColor *)currentPageindicatorTintColor {
    
    _currentPageindicatorTintColor = currentPageindicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageindicatorTintColor;
}

- (void)setTimeInterval:(CGFloat)timeInterval {
    
    _timeInterval = timeInterval;
    
    if (self.jzTimer) {
        [self.jzTimer invalidate];
        self.jzTimer = nil;
        [self initJZTimer];
    } else {
        [self initJZTimer];
    }
}

// MARK: 防止定时器强引用无法释放
- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (!newSuperview && self.jzTimer) {
        [self.jzTimer invalidate];
        self.jzTimer = nil;
    }
}

@end

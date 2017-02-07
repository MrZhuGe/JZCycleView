//
//  JZCCycleView.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "JZCCycleView.h"
#import "JZCCycleViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString * const JZCCYCLEVIEWCELLID = @"JZCCYCLEVIEWCELLID";

NSInteger const CMAXSCALE = 100;

@interface JZCCycleView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// 轮播图片地址数组
@property (nonatomic, strong) NSArray                       *imageURL;

// 设置文字是否隐藏的数组，默认为YES;
@property (nonatomic, strong) NSArray                       <NSNumber *> *valueHides;

@property (nonatomic, strong) UICollectionView              *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;

// 轮播计时器
@property (nonatomic, strong) NSTimer                       *jzTimer;

// 时间计时器
@property (nonatomic, strong) NSTimer                       *timeTimer;

@property (nonatomic, strong) UIPageControl                 *pageControl;

// 系统时间
@property (nonatomic, assign) NSUInteger                    sysTime;

// 开始时间
@property (nonatomic, assign) NSUInteger                    startTime;

// 结束时间
@property (nonatomic, assign) NSUInteger                    endTime;

@end

@implementation JZCCycleView

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
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.minimumLineSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.itemSize = self.frame.size;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[JZCCycleViewCell class] forCellWithReuseIdentifier:JZCCYCLEVIEWCELLID];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 37, self.frame.size.width - 30, 37)];
    self.pageControl.enabled = NO;
    [self addSubview:self.pageControl];
}

// MARK: UICollectionViewDataSource && UICollectionViewDelegate
// 单元
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageURL.count * CMAXSCALE;
}

// 设置cell单元
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JZCCycleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JZCCYCLEVIEWCELLID forIndexPath:indexPath];
    
    NSInteger itemIndex = indexPath.item % self.imageURL.count;
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL[itemIndex]]];
    
    if (self.valueHides && self.valueHides.count == self.imageURL.count) {
        cell.valueLabel.hidden = [self.valueHides[itemIndex] boolValue];
        
        if (self.sysTime > self.endTime) {
            cell.valueLabel.hidden = YES;
        } else {
            NSString *time = [self timeWithServerTime:self.sysTime endTime:self.endTime];
            if (self.sysTime < self.startTime) {
                cell.valueLabel.text = [NSString stringWithFormat:@"距开始 %@", time];
            } else if (self.sysTime >= self.startTime && self.sysTime < self.endTime) {
                cell.valueLabel.text = [NSString stringWithFormat:@"距结束 %@", time];
            }
        }
    } else {
        cell.valueLabel.hidden = YES;
    }
    
    return cell;
}

// UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(jzCCycleView:clickIndex:)]) {
        
        NSInteger itemIndex = indexPath.item % self.imageURL.count;
        [self.delegate jzCCycleView:self clickIndex:itemIndex];
    }
}

// MARK: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger itemIndex = [self currentIndex];
    NSInteger indexOnPageControl = itemIndex % self.imageURL.count;
    self.pageControl.currentPage = indexOnPageControl;
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
    
    if (self.imageURL.count == 0) {
        return;
    }
    
    NSInteger currentIndex = [self currentIndex];
    NSInteger targetIndex = currentIndex + 1;
    if (targetIndex >= self.imageURL.count * CMAXSCALE) {
        
        targetIndex = self.imageURL.count * CMAXSCALE * 0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)onTimeTiemr:(NSTimer *)timer {
    
    if (self.sysTime > 0) {
        
        ++self.sysTime;
        
        [self.collectionView reloadData];
    }
}

// MARK: 当前索引
- (NSInteger)currentIndex {
    
    NSInteger index = 0;
    if (self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + self.layout.itemSize.width * 0.5) / self.layout.itemSize.width;
    }
    return MAX(0, index);
}

// 设置图片地址数组，文字是否隐藏数组
- (void)addImagePaths:(NSArray *)imagePaths valueHides:(NSArray <NSNumber *> *)valueHides {
    
    self.imageURL = imagePaths;
    self.valueHides = valueHides;
    
    if (imagePaths.count == 0) {
        return;
    }
    
    if (imagePaths.count != valueHides.count) {
        return;
    }
    
    if (imagePaths.count == 1) {
        self.collectionView.scrollEnabled = NO;
    }
    
    self.pageControl.numberOfPages = imagePaths.count;
    
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:imagePaths.count * CMAXSCALE/2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    // 启动定时器
    if (imagePaths.count > 1) {
        
        if (self.jzTimer) {
            [self.jzTimer invalidate];
            self.jzTimer = nil;
            [self initJZTimer];
        } else {
            [self initJZTimer];
        }
    }
}

// 设置系统时间，开始时间，结束时间
- (void)addSysTime:(NSString *)sysTime startTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    if (!self.imageURL || self.imageURL.count == 0) {
        return;
    }
    
    self.sysTime = sysTime.integerValue;
    self.startTime = startTime.integerValue;
    self.endTime = endTime.integerValue;
    
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimeTiemr:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timeTimer forMode:NSRunLoopCommonModes];
}

// MARK: Setter
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
    
    if (!newSuperview && self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

// MARK: 根据当前时间返回剩余时间(xx天xx小时xx分xx秒)
- (NSString *)timeWithServerTime:(NSUInteger)serverTime endTime:(NSUInteger)endTime {
    
    NSUInteger totalTime = endTime - serverTime;
    
    // 剩余天数
    NSUInteger day = totalTime/(24 * 3600);
    
    // 剩余小时
    NSUInteger hour = (totalTime%(24 * 3600))/3600;
    
    // 剩余分钟
    NSUInteger min = (totalTime%3600)/60;
    
    // 剩余秒数
    NSUInteger sec = totalTime%60;
    
    NSString *time = [NSString stringWithFormat:@"%ld天%02ld时%02ld分%02ld秒", day, hour, min, sec];
    
    return time;
}

@end

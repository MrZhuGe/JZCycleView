//
//  JZCFCycleView.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/25.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "JZCFCycleView.h"
#import "JZCFCycleViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString * const JZCFCYCLEVIEWCELLID = @"JZCCYCLEVIEWCELLID";

NSInteger const CFMAXSCALE = 100;

@interface JZCFCycleView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView              *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout    *layout;

@property (nonatomic, strong) NSTimer                       *jzTimer;

@property (nonatomic, strong) UIPageControl                 *pageControl;

@end

@implementation JZCFCycleView

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
    self.layout.itemSize = CGSizeMake(self.frame.size.width - 80, self.frame.size.height - 30);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30) collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[JZCFCycleViewCell class] forCellWithReuseIdentifier:JZCFCYCLEVIEWCELLID];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 37, self.frame.size.width - 30, 37)];
    self.pageControl.enabled = NO;
    [self addSubview:self.pageControl];
}

// MARK: UICollectionViewDataSource && UICollectionViewDelegate
// 单元
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imageURL.count * CFMAXSCALE;
}

// 设置cell单元
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JZCFCycleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JZCFCYCLEVIEWCELLID forIndexPath:indexPath];
    
    NSInteger itemIndex = indexPath.item % self.imageURL.count;
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL[itemIndex]]];
    
    return cell;
}

// UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(jzCFCycleView:clickIndex:)]) {
        
        NSInteger itemIndex = indexPath.item % self.imageURL.count;
        [self.delegate jzCFCycleView:self clickIndex:itemIndex];
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
    if (targetIndex >= self.imageURL.count * CFMAXSCALE) {
        
        targetIndex = self.imageURL.count * CFMAXSCALE * 0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

// MARK: 当前索引
- (NSInteger)currentIndex {
    
    NSInteger index = 0;
    if (self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + self.layout.itemSize.width * 0.5) / self.layout.itemSize.width;
    }
    return MAX(0, index);
}

// MARK: Setter
- (void)setImageURL:(NSArray *)imageURL {
    _imageURL = imageURL;
    
    if (imageURL.count == 0) {
        return;
    }
    
    if (imageURL.count == 1) {
        self.collectionView.scrollEnabled = NO;
    }
    
    self.pageControl.numberOfPages = imageURL.count;
    
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:imageURL.count * CFMAXSCALE/2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
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

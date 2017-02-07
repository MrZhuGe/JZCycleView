//
//  JZCycleView.h
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZCycleView;

@protocol JZCycleViewDelegate <NSObject>

- (void)jzCycleView:(JZCycleView *)cycleView clickIndex:(NSInteger)index;

@end

@interface JZCycleView : UIView

// 轮播图片地址数组
@property (nonatomic, strong) NSArray *imageURL;

@property (nonatomic, weak) id <JZCycleViewDelegate> delegate;

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

@property (nonatomic, strong) UIColor *currentPageindicatorTintColor;

// 轮播图展示时间，默认为2秒
@property (nonatomic, assign) CGFloat timeInterval;

@end

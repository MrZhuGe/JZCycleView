//
//  JZCCycleView.h
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JZCCycleView;

@protocol JZCCycleViewDelegate <NSObject>

- (void)jzCCycleView:(JZCCycleView *)cycleView clickIndex:(NSInteger)index;

@end

@interface JZCCycleView : UIView

@property (nonatomic, weak) id <JZCCycleViewDelegate> delegate;

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

@property (nonatomic, strong) UIColor *currentPageindicatorTintColor;

// 轮播图展示时间，默认为2秒
@property (nonatomic, assign) CGFloat timeInterval;

// 设置图片地址数组，文字是否隐藏数组
- (void)addImagePaths:(NSArray *)imagePaths valueHides:(NSArray <NSNumber *> *)valueHides;

// 设置系统时间，开始时间，结束时间
- (void)addSysTime:(NSString *)sysTime startTime:(NSString *)startTime endTime:(NSString *)endTime;

@end

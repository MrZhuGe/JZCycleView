//
//  JZCFCycleViewCell.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/25.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "JZCFCycleViewCell.h"

@implementation JZCFCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}

// MARK: 初始化
- (void)initView {
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (self.contentView.frame.size.height - 24) * 1.78, self.contentView.frame.size.height - 24)];
    self.imageView.center = self.contentView.center;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 5.0f;
    [self.contentView addSubview:self.imageView];
}

@end

//
//  JZCCycleViewCell.m
//  JZCycleView
//
//  Created by 郑家柱 on 2017/1/24.
//  Copyright © 2017年 Mobcb. All rights reserved.
//

#import "JZCCycleViewCell.h"

@implementation JZCCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}

// MARK: 初始化
- (void)initView {
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.imageView];
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.valueLabel.center = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height - 50);
    self.valueLabel.backgroundColor = [UIColor colorWithRed:51/255.0f green:172/255.0f blue:255/255.0f alpha:1.0f];
    self.valueLabel.font = [UIFont systemFontOfSize:14];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.layer.masksToBounds = YES;
    self.valueLabel.layer.cornerRadius = 30/2;
    [self.contentView addSubview:self.valueLabel];
}

@end

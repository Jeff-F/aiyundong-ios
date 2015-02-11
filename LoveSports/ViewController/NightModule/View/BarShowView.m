//
//  BarShowView.m
//  ZKKUIViewExtension
//
//  Created by zorro on 15/2/10.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BarShowView.h"
#import "BarGraphView.h"

@interface BarShowView ()

@property (nonatomic, strong) BarGraphView *barView;

@end

@implementation BarShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self loadLabels];
        [self loadBarGraphView];
    }
    
    return self;
}

- (void)loadLabels
{
    for (int i = 24; i < 49; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 + self.frame.size.width/49*(i-24), self.frame.size.height - 14, self.frame.size.width/49, 14)];
        
        NSString *string = [NSString stringWithFormat:@"%02d:%@", i / 2, (((i % 2) == 0) ? @"00" : @"30")];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text = string;
        [self addSubview:label];
    }
    
    for (int i = 1; i <= 24; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 + self.frame.size.width/49*(i+24), self.frame.size.height - 14, self.frame.size.width/49, 14)];
        
        NSString *string = [NSString stringWithFormat:@"%02d:%@", i / 2, (((i % 2) == 0) ? @"00" : @"30")];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text = string;
        [self addSubview:label];
    }
}

- (void)loadBarGraphView
{
    _barView = [[BarGraphView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 14)];
    
    [self addSubview:_barView];
}

- (void)updateContentForView:(NSArray *)array
{
    _barView.array = array;
}

@end

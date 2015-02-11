//
//  TrendChartView.m
//  LoveSports
//
//  Created by zorro on 15/2/7.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "TrendChartView.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "ShowWareView.h"
#import "CalendarHomeView.h"
#import "PedometerModel.h"

@interface TrendChartView ()

@property (nonatomic, strong) FSLineChart *lineChart;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UISegmentedControl *segement;
@property (nonatomic, assign) NSInteger segIndex;

@property (nonatomic, strong) CalendarHomeView *calenderView;
@property (nonatomic, strong) UIButton *lastButton;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger percent;

@end

@implementation TrendChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.contents = (id)[UIImage imageNamed:@"background@2x.jpg"].CGImage;
        
        _currentDate = [NSDate date];
        
        [self loadCalendarButton];
        [self loadSegmentedControl];
        [self loadLandscapeButton];
        [self loadLineChart];
    }
    
    return self;
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = currentDate;
    
    [self updateContentForChartViewWithDirection:0];
}

- (void)loadCalendarButton
{
    UIButton *calendarButton = [UIButton simpleWithRect:CGRectMake(15, 70, 45, 35)
                                              withImage:@"日历.png"
                                        withSelectImage:@"日历.png"];
    
    [calendarButton addTarget:self action:@selector(clickCalendarButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:calendarButton];
}

- (void)clickCalendarButton
{
    if (!_calenderView)
    {
        _calenderView = [[CalendarHomeView alloc] initWithFrame:CGRectMake(2, self.height * 0.15, self.width - 4.0, self.height * 0.8)];
    }
    
    [_calenderView setLoveSportsToDay:365 ToDateforString:nil];
    DEF_WEAKSELF_(TrendChartView);
    _calenderView.calendarblock = ^(CalendarDayModel *model) {
        NSLog(@"..%@", [model date]);
        weakSelf.currentDate = [model date];
    };
    
    [_calenderView popupWithtype:PopupViewOption_colorLump touchOutsideHidden:YES succeedBlock:^(UIView *_view) {
    } dismissBlock:^(UIView *_view) {
        [_calenderView removeFromSuperview];
        _calenderView = nil;
    }];
}

- (void)loadSegmentedControl
{
    _segement = [[UISegmentedControl alloc] initWithItems:@[@"日", @"周", @"月"]];
    _segement.frame = CGRectMake((self.width - 200) / 2, 30, 200, 40);
    
    _segement.backgroundColor = [UIColor clearColor];
    _segement.tintColor = [UIColor clearColor];
    //[_segement setBackgroundImage:[UIImage image:@"日@2x.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segement setImage:[UIImage image:@"日选中@2x.png"] forSegmentAtIndex:0];
    [_segement setImage:[UIImage image:@"周@2x.png"] forSegmentAtIndex:1];
    [_segement setImage:[UIImage image:@"月@2x.png"] forSegmentAtIndex:2];
    [_segement addTarget:self action:@selector(clickSegementControl:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segement];
    _segIndex = 0;
}

// 日月周趋势切换
- (void)clickSegementControl:(UISegmentedControl *)seg
{
    NSArray *images = @[@"日@2x.png", @"周@2x.png", @"月@2x.png"];
    NSArray *selectImages = @[@"日选中@2x.png", @"周选中@2x.png", @"月选中@2x.png"];
    
    [_segement setImage:[UIImage image:images[_segIndex]]
      forSegmentAtIndex:_segIndex];
    [_segement setImage:[UIImage image:selectImages[_segement.selectedSegmentIndex]]
      forSegmentAtIndex:_segement.selectedSegmentIndex];
    _segIndex = _segement.selectedSegmentIndex;
    
    if (_segement.selectedSegmentIndex == 0)
    {
        // 日
    }
    else if (_segement.selectedSegmentIndex == 1)
    {
        // 周
    }
    else
    {
        // 月
    }
}

- (void)loadLandscapeButton
{
    UIButton *landscapeButton = [UIButton simpleWithRect:CGRectMake(self.width - 60, 70, 45, 35)
                                               withImage:@"竖屏@2x.png"
                                         withSelectImage:@"竖屏@2x.png"];
    
    [landscapeButton addTarget:self action:@selector(landscapeViewData) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:landscapeButton];
}

- (void)landscapeViewData
{
    if ([_delegate respondsToSelector:@selector(trendChartViewLandscape:)])
    {
        [_delegate trendChartViewLandscape:self];
    }
}

- (void)loadDateLabel
{
    _weekLabel = [UILabel customLabelWithRect:CGRectMake(0, 25, self.width, 30)
                                    withColor:[UIColor clearColor]
                                withAlignment:NSTextAlignmentCenter
                                 withFontSize:20
                                     withText:@"星期一"
                                withTextColor:[UIColor whiteColor]];
    [self addSubview:_weekLabel];
    
    _dateLabel = [UILabel customLabelWithRect:CGRectMake(0, 50, self.width, 30)
                                    withColor:[UIColor clearColor]
                                withAlignment:NSTextAlignmentCenter
                                 withFontSize:20
                                     withText:@"2015/2/2"
                                withTextColor:[UIColor whiteColor]];
    [self addSubview:_dateLabel];
}

#define TrendChartView_LevelNumber 800
-(void)loadLineChart
{
    // Generating some dummy data
 
    CGRect rect = CGRectMake((self.width - self.width * 0.9) / 2, 120, self.width * 0.9, 200);
    _lineChart = [[FSLineChart alloc] initWithFrame:rect];
    _lineChart.verticalGridStep = 6;
    _lineChart.horizontalGridStep = 8; // 151,187,205,0.2
    _lineChart.levelNumber = TrendChartView_LevelNumber;
    _lineChart.color = [UIColor colorWithRed:151.0f/255.0f green:187.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    _lineChart.fillColor = [_lineChart.color colorWithAlphaComponent:0.3];
    _lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@""];
    };
    [self addSubview:_lineChart];
    
    [self refreshTrendChartViewWithDate:_currentDate];
}

- (void)refreshTrendChartViewWithDate:(NSDate *)date
{
    _currentDate = date;
    NSArray *array = [PedometerModel getEveryDayTrendDataWithDate:_currentDate];
    NSMutableArray *chartDataArray = [[NSMutableArray alloc] init];
    NSMutableArray *daysArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < array.count; i++)
    {
        PedometerModel *model = array[i];
        if (_lastButton.tag == 2000)
        {
            chartDataArray[i] = @(model.totalSteps);
            _lineChart.levelNumber = TrendChartView_LevelNumber;
        }
        else if (_lastButton.tag == 2001)
        {
            chartDataArray[i] = @(model.totalCalories);
            _lineChart.levelNumber = [self stepsConvertCalories:TrendChartView_LevelNumber withWeight:model.weight withModel:YES];
        }
        else
        {
            chartDataArray[i] = @(model.totalDistance);
            _lineChart.levelNumber = [self StepsConvertDistance:TrendChartView_LevelNumber withPace:model.stepSize];
        }
        
        chartDataArray[i] = @(model.totalSteps);
        daysArray[i] = [model.dateString substringFromIndex:5];
    }
    
    _lineChart.labelForIndex = ^(NSUInteger item) {
        return daysArray[item];
    };
    [_lineChart setChartData:chartDataArray];
}

- (void)updateContentForChartViewWithDirection:(NSInteger)direction
{
    [self refreshTrendChartViewWithDate:[_currentDate dateAfterDay:((int)direction * 8)]];
}

// 步数，卡路里，距离切换.
- (void)loadChartStyleButtons
{
    CGFloat offsetX = ((self.width - 60) - 90 * 3) / 2;
    NSArray *images = @[@"足迹@2x.png", @"能量@2x.png", @"路程@2x.png"];
    NSArray *selectImages = @[@"足迹-选中@2x.png", @"能量选中@2x.png", @"路程选中@2x.png"];
    
    for (int i = 0; i < images.count; i++)
    {
        UIButton *button = [UIButton simpleWithRect:CGRectMake(30 + (90 + offsetX) * i , 340, 90, 89)
                                          withImage:images[i]
                                    withSelectImage:selectImages[i]];
        
        button.tag = 2000 + i;
        [button addTarget:self action:@selector(clcikChartStyleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (i == 0)
        {
            button.selected = YES;
            _lastButton = button;
        }
    }
}

- (void)clcikChartStyleButton:(UIButton *)button
{
    _lastButton.selected = NO;
    button.selected = YES;
    _lastButton = button;
    
    [self refreshTrendChartViewWithDate:_currentDate];
}

- (void)loadShareButton
{
    UIButton *calendarButton = [UIButton simpleWithRect:CGRectMake(self.width - 45, self.height - 99, 90/2.0, 70/2.0)
                                              withImage:@"分享@2x.png"
                                        withSelectImage:@"分享@2x.png"];
    
    [self addSubview:calendarButton];
}

@end

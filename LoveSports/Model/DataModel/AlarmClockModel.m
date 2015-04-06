//
//  AlarmClockModel.m
//  LoveSports
//
//  Created by zorro on 15/4/4.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "AlarmClockModel.h"

@implementation AlarmClockModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isOpen = NO;
        _alarmTime = @"12:00";
        _repeat = 0;
        _height = 56.0;
        _seconds = 0;
    }
    
    return self;
}

/**
 *  得到一个代表星期几的Uint8
 *
 *  @param weekNumber 0~7，1：代表每周一, 0代表无
 *
 *  @return 得到的Uint8
 */
+ (UInt8) getAUint8FromeWeekNumber: (NSInteger) weekNumber
{
    if (weekNumber == 0 || weekNumber > 7)
    {
        return 00000000;
    }
    UTF8Char repeatCharModel = 00000001;
    return repeatCharModel << weekNumber;
    
}

/**
 *  设置所有时间（时分秒&重复周期）
 *
 *  @param timeString  格式：23:01 或者  23:01:45
 *  @param repeatUntStringArray 装uint8的字符串数组如【@"1", @"2"】,代表每周一周二重复
 *  @param isFullWeekDay  是否是每天重复（周1至周日全部重复）
 */
- (void) setAllTimeFromTimeString: (NSString *) timeString
         withRepeatUntStringArray: (NSArray *) repeatUntStringArray
                  withFullWeekDay: (BOOL) isFullWeekDay
{
    if ([NSString isNilOrEmpty:timeString])
    {
        NSLog(@"字符串格式不符合要求");
        return;
    }
    NSArray *timeArray = [timeString componentsSeparatedByString:@":"];
    if ([timeArray count] < 2)
    {
        NSLog(@"字符串格式不符合要求");
        return;
    }
    self.hour = [[timeArray objectAtIndex:0] intValue];
    
    self.minutes = [[timeArray objectAtIndex:1] intValue];
    
    if ([timeArray count] == 3)
    {
        self.seconds = [[timeArray objectAtIndex:2] intValue];
    }
    else
    {
        self.seconds = 0;
    }
    
    if (isFullWeekDay)
    {
        self.repeat = 01111111;
        return;
    }
    
    UTF8Char repeatChar = 00000000;
    for (NSString *tempNumberString in repeatUntStringArray)
    {
        UInt8 tempUnt = [AlarmClockModel getAUint8FromeWeekNumber:[tempNumberString integerValue]];
        repeatChar = repeatChar || tempUnt;
    }
    self.repeat = repeatChar;
}

+ (NSArray *)getAlarmClockFromDB
{
    NSArray *array = [AlarmClockModel searchWithWhere:nil orderBy:@"orderIndex" offset:0 count:5];
    
    if (!array || array.count == 0)
    {
        NSMutableArray *alarmArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < 5; i++)
        {
            AlarmClockModel *model = [AlarmClockModel simpleInitWith:i];
            
            [model saveToDB];
            [alarmArray addObject:model];
        }
        
        return alarmArray;
    }
    
    return array;
}

+ (AlarmClockModel *)simpleInitWith:(NSInteger)index
{
    AlarmClockModel *model = [[AlarmClockModel alloc] init];
    
    model.orderIndex = index;
    
    return model;
}

- (NSArray *)sortByNumberWithArray:(NSArray *)array withSEC:(BOOL)sec
{
    NSMutableArray *muArray = [NSMutableArray arrayWithArray:array];
    
    [muArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSString *string1 = (NSString *)obj1;
         NSString *string2 = (NSString *)obj2;
         
         if (([string1 integerValue] > [string2 integerValue]) == sec)
         {
             return NSOrderedAscending;
         }
         else
         {
             return NSOrderedDescending;
         }
     }];
    
    return muArray;
}

- (NSString *)showStringForWeekDay
{
    NSArray *weekArray = [self sortByNumberWithArray:_weekArray withSEC:NO];
    NSDictionary *dict = @{@"0" : @"日", @"1" : @"一", @"2" : @"二",
                           @"3" : @"三", @"4" : @"四", @"5" : @"五", @"6" : @"六"};
    
    NSString *weekString = weekArray.count > 0 ? @"周" : @"";
    
    for (int i = 0; i < weekArray.count; i++)
    {
        NSString *day = weekArray[i];
        NSString *string = [dict objectForKey:day];
        
        if (i != _weekArray.count - 1)
        {
            weekString = [NSString stringWithFormat:@"%@%@, ", weekString, string];
        }
        else
        {
            weekString = [NSString stringWithFormat:@"%@%@", weekString, string];
        }
    }
    
    return weekString;
}

- (void)convertToBLTNeed
{
    UInt8 val = 0;
    for (int i = 0; i < 7; i++)
    {
        if ([_weekArray containsObject:[NSString stringWithFormat:@"%d", i]])
        {
            val = val | (1 << i);
        }
        else
        {
            val = val | (0 << i);
        }
    }

    _repeat = val | ( _isOpen << 7);
    NSArray *array = [_alarmTime componentsSeparatedByString:@":"];
    _hour = [array[0] integerValue];
    _minutes = [array[1] integerValue];
}

// 表名
+ (NSString *)getTableName
{
    return @"AlarmClockModel";
}

// 复合主键
+ (NSArray *)getPrimaryKeyUnionArray
{
    return @[@"userName", @"orderIndex"];
}

// 表版本
+ (int)getTableVersion
{
    return 1;
}

@end
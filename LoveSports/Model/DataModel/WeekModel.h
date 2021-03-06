//
//  WeekModel.h
//  LoveSports
//
//  Created by jamie on 15/2/8.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PedometerModel.h"
#import "DateTools.h"

@interface SubOfPedometerModel : NSObject  //pedometermodel子模型

@property (nonatomic, assign) NSInteger _thisDayTotalSteps;         // 当天的总步数
@property (nonatomic, assign) NSInteger _thisDayTotalCalories;      // 当天的总卡路里
@property (nonatomic, assign) NSInteger _thisDayTotalDistance ;     // 当天的总路程

/**
 *  更新此子模型的信息通过传入的pedometerModel模型
 *
 *  @param onePedometerModel 传入的pedometerModel模型
 */
- (void) updateInfoFromAPedometerModel: (PedometerModel *) onePedometerModel;

@end

@interface WeekModel : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *wareUUID;
@property (nonatomic, assign) NSInteger weekNumber;         // 第几周
@property (nonatomic, assign) NSInteger yearNumber;         // 年，如2014
@property (nonatomic, assign) NSInteger weekTotalSteps;     // 本周的总步数
@property (nonatomic, assign) NSInteger weekTotalCalories;  // 本周的总卡路里
@property (nonatomic, assign) NSInteger weekTotalDistance ; // 本周的总路程
@property (nonatomic, strong) NSString *showDate;

@property (nonatomic, assign) NSInteger todaySteps;     // 当天的总步数
@property (nonatomic, assign) NSInteger toadyCalories;  // 当天的总卡路里
@property (nonatomic, assign) NSInteger todayDistance ; // 当天的总路程
/**
 *  初始化一个星期模型
 *
 *  @param weekNumber 这个星期是那一年的第几周
 *  @param andYearNumber 表示是哪一年
 *
 *  @return 星期模型
 */
- (instancetype)initWithWeekNumber:(NSInteger ) weekNumber
                     andYearNumber: (NSInteger ) yearNumber;


/**
 *  更新汇总信息
 */
- (void) updateInfo;
- (void)updateTotalWithModel:(PedometerModel *)model;

@end


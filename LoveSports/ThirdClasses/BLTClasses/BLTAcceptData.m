//
//  BLTAcceptData.m
//  LoveSports
//
//  Created by zorro on 15-1-27.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTAcceptData.h"
#import "PedometerModel.h"
#import "Header.h"

@implementation BLTAcceptData

DEF_SINGLETON(BLTAcceptData)

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _syncData = [[NSMutableData alloc] init];
        _realTimeData = [[NSMutableData alloc] init];
        _realTimeType = BLTAcceptDataTypeUnKnown;
        
        // 直接启动蓝牙
        [BLTManager sharedInstance];
        
        /**
         *  普通数据得更新
         *
         *  @param data 传入得数据data
         *
         *  @return
         */
        [BLTPeripheral sharedInstance].updateBlock = ^(NSData *data) {
            [self acceptData:data];
        };
        
        /**
         *  同步时传入得大数据。
         *
         *  @param data 
         *
         *  @return
         */
        [BLTPeripheral sharedInstance].updateBigDataBlock = ^(NSData *data) {
            [self updateBigData:data];
        };
        
        // 实时传输的数据
        [BLTPeripheral sharedInstance].realTimeBlock = ^(NSData *data) {
            [self saveRealTimeData:data];
        };
    }
    
    return self;
}

- (void)setType:(BLTAcceptDataType)type
{
    _type = type;
    
    if (_type == BLTAcceptDataTypeUnKnown)
    {
        // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkWhetherCommunicationError) object:nil];
        // [self performSelector:@selector(checkWhetherCommunicationError) withObject:nil afterDelay:2.0];
    }
}

- (void)acceptData:(NSData *)data
{
    _type = BLTAcceptDataTypeSuccess;
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    
    id object = nil;
    int order = val[2];
    NSLog(@"--------%0x, %0x, %0x, %0x", val[0], val[1], val[2], val[3]);
    
    if (val[0] == 0xDE)
    {
        if (val[1] == 0x01)
        {
            if (order == 0x01)
            {
                // SHOWMBProgressHUD(@"设置成功...", nil, nil, NO, 2);
                [LS_SettingBaseTimeZoneInfo setBOOLValue:YES];

                // 设定时区英制基本信息成功.
                _type = BLTAcceptDataTypeSetActiveTimeZone;
            }
            else if (order == 0x02)
            {
                if (val[3] == 0xED)
                {
                    // 设定本地时间，时区成功
                    _type = BLTAcceptDataTypeSetCurrentTime;
                }
                else if (val[3] == 0xFB)
                {
                    _type = BLTAcceptDataTypeCheckWareTime;
                    NSString *string = [NSString stringWithFormat:@"当前设备时间: \n%d月%d日 %d:%d \n时区:%d", val[6], val[7], val[10], val[11], val[9]];
                    object = string;
                    // 计步器发送时间到手机.
                }
            }
            else if (order == 0x03)
            {
                if(val[3] == 0xED)
                {
                    // 设定用户身体信息成功
                    _type = BLTAcceptDataTypeSetUserInfo;
                }
                else if (val[3] == 0x00)
                {
                    // 每天设定已经超过10次.
                    _type = BLTAcceptDataTypeSetUserInfo;
                }
                else if (val[3] == 0xFB)
                {
                    // 计步器发送身体信息到手机
                    _type = BLTAcceptDataTypeCheckWareUserInfo;
                }
            }
            else if (order == 0x04)
            {
                // 固件屏幕颜色设定成功
                _type = BLTAcceptDataTypeSetWareScreenColor;
            }
            else if (order == 0x05)
            {
                if (val[3] == 0xED)
                {
                    // 设定密码保护
                    _type = BLTAcceptDataTypeSetPassword;
                }
                else if (val[3] == 0xFB)
                {
                    // 返回设备密码
                    _type = BLTAcceptDataTypeSetPassword;
                }
            }
            else if (order == 0x06)
            {
                // 设定固件启动方式
                _type = BLTAcceptDataTypeSetOpenModel;
            }
            else if (order == 0x07)
            {
                // 智能睡眠提醒
                _type = BLTAcceptDataTypeSetSleepRemind;
            }
            else if (order == 0x08)
            {
                // 自定义显示界面
                _type = BLTAcceptDataTypeCheckWareTime;
            }
            else if (order == 0x09)
            {
                // 自定义闹钟
                _type = BLTAcceptDataTypeSetAlarmClock;
            }
            else if (order == 0x0A)
            {
                // 进入校正模式.
                _type = BLTAcceptDataTypeCorrectionCommand;
            }
            else if (order == 0x0B)
            {
                // 设定佩戴方式
                _type = BLTAcceptDataTypeSetWearingWay;
            }
            else if (order == 0x0C)
            {
                // 久坐提醒设定
                _type = BLTAcceptDataTypeSetSedentaryRemind;
            }
            else if (order == 0x0D)
            {
                // 设定出厂模式.
                _type = BLTAcceptDataTypeSetFactoryModel;
            }
            else if (order == 0x0E)
            {
                // 修改设备名称
                _type = BLTAcceptDataTypeChangeWareName;
            }
            else if (order == 0x0F)
            {
                // 显示当前密码
                _type = BLTAcceptDataTypeShowWarePassword;
            }
            else if (order == 0x10)
            {
                // 校正模式下的当前位置.
                // 非校正模式下智能起床
                _type = BLTAcceptDataTypeSetIntelGetup;
            }
            else if (order == 0x11)
            {
                // 开始背光设定
                _type = BLTAcceptDataTypeSetOpenBackLight;
            }
            else if (order == 0x12)
            {
                // 收到联系人的名字.
                _type = BLTAcceptDataTypeSetContactToWare;
            }
            else if (order == 0x13)
            {
                // 收到联系人的电话号码.
                _type = BLTAcceptDataTypeSetTelToWare;
            }
            else if (order == 0x14)
            {
                // 校正模式下的当前位置.
                _type = BLTAcceptDataTypeSetPositionToWare;
            }
        }
        else if (val[1] == 0x02)
        {
            if (order == 0x01)
            {
                if (val[3] == 0xED)
                {
                    // 请求历史运动数据完毕.
                    _type = BLTAcceptDataTypeRequestHistorySportsData;
                    object = _syncData;
                }
                else if (val[3] == 0x06)
                {
                    // 无数据
                    _type = BLTAcceptDataTypeRequestHistoryNoData;
                }
                else if (val[3] == 0xFE)
                {
                   _realTimeType = BLTAcceptDataTypeRealTimeTransState;
                    
                    // [[BLTRealTime sharedInstance] saveRealTimeDataToDBAndUpdateUI:_realTimeData];
                }
            }
            else if (order == 0x02)
            {
                if (val[3] == 0xED)
                {
                    // 删除运动数据
                    _type = BLTAcceptDataTypeDeleteSportsData;
                }
            }
            else if (order == 0x03)
            {
                if (val[3] == 0xED || val[3] == 0xFE)
                {
                    //  计步器收到开始实时传输数据的命令
                    _type = BLTAcceptDataTypeRealTimeTransSportsData;
                }
            }
            else if (order == 0x04)
            {
                if (val[3] == 0xED)
                {
                    // 计步器收到关闭实时传输数据的命令
                    _type = BLTAcceptDataTypeCloseTransSportsData;
                }
            }
            else if (order == 0x05)
            {
                if (val[3] == 0xED)
                {
                 
                }
                else if (val[3] == 0xFB)
                {
                    // 请求历史运动数据的保存日期
                    _type = BLTAcceptDataTypeRequestHistoryDate;
                    
                    NSString *startDate = [NSString stringWithFormat:@"%04d-%02d-%02d", ((val[4] << 8) | val[5]), val[6], val[7]];
                    NSString *endDate = [NSString stringWithFormat:@"%04d-%02d-%02d", ((val[8] << 8) | val[9]), val[10], val[11]];
                    
                    NSLog(@"请求历史运动数据的保存日期..%@..%@", startDate, endDate);
                    object = @[startDate, endDate];
                }
            }
        }
        else if (val[1] == 0x06)
        {
            if (val[2] == 0x09)
            {
                if (val[3] == 0xFB)
                {
                    // 当前硬件以及固件的信息.
                    _type = BLTAcceptDataTypeInfoAboutHardAndFirm;
                    
                    object = data;
                }
            }
        }
    }
    else if (val[0] == 0xBE)
    {
        if (val[1] == 0x02)
        {
            if (val[2] == 0x03)
            {
                if (val[3] == 0xFE)
                {
                    _type = BLTAcceptDataTypeRealTimeTransSportsData;
                }
            }
        }
    }
    else if (val[0] == 0x86)
    {
        if (val[1] == 0)
        {
            if (val[2] == 01)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldSetUserInfo;
                }
            }
            else if (val[2] == 0x0A)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldSetAlarmClock;
                }
            }
            else if (val[2] == 6)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldRequestDataLength;
                    _dataLength = val[4] | val[5] << 8;
                    object = @(_dataLength);
                    
                    NSLog(@"length...%d..%d..%@", val[4], val[5], object);
                }
            }
            else if (val[2] == 0x07)
            {
                if (val[3] == 01)
                {
                    // 旧设备请求运动数据完毕.
                    _type = BLTAcceptDataTypeOldRequestSportEnd;
                    object = _syncData;
                }
            }
            else if (val[2] == 0x0B)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldSetWearingWay;
                }
            }
            else if (val[2] == 0x0C)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldSetWearingWay;
                }
            }
            else if (val[2] == 0x0D)
            {
                if (val[3] == 01)
                {
                    _type = BLTAcceptDataTypeOldEventInfo;
                }
            }
            else if (val[2] == 0x0E)
            {
                _type = BLTAcceptDataTypeOldDeleteSuccess;
            }
        }
        else if (val[1] == 0xAA)
        {
            if (val[2] == 7)
            {
                if (val[3] == 1)
                {
                    // 旧设备请求运动数据完毕.
                    _type = BLTAcceptDataTypeOldRequestSportEnd;
                    object = _syncData;
                }
                else if (val[4] == 6)
                {
                    _type = BLTAcceptDataTypeOldRequestSportNoData;
                }
            }
        }
        else if (val[1] == 2)
        {
            if (val[2] == 1)
            {
                _type = BLTAcceptDataTypeOldRequestUserInfo;
            }
        }
    }
    
    if (_updateValue)
    {
        _updateValue(object, _type);
        _updateValue = nil;
    }
}

- (void)updateBigData:(NSData *)data
{
    _type = BLTAcceptDataTypeRequestHistorySportsData;
    
    // 重新等待.
    [BLTSimpleSend sharedInstance].waitTime = 0;
    
    [_syncData appendData:data];
    [self showProgress];
}

- (void)showProgress
{
    if (![BLTManager sharedInstance].model.isNewDevice)
    {
        if (_dataLength == 0)
        {
            return;
        }
        
        CGFloat progress = (_syncData.length - _syncData.length / 20) * 1.0 / _dataLength;
        
        if (progress > 1.000)
        {
            progress = 1.0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = [NSString stringWithFormat:@"%@: %.0f%%", LS_Text(@"Synchronous progress"), progress * 100];
            SHOWMBProgressHUDIndeterminate(title, nil, NO);
        });

        if (progress >= 0.99)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenProgress) object:nil];
            [self performSelector:@selector(hiddenProgress) withObject:nil afterDelay:10.0];
        }
    }
}

- (void)hiddenProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HIDDENMBProgressHUD;
    });
}

- (void)saveRealTimeData:(NSData *)data
{
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    if (val[0] == 0xDE)
    {
        [self cleanMutableRealTimeData];
    }
    
    _realTimeType = BLTAcceptDataTypeRealTimeTransState;
    [_realTimeData appendData:data];

    if (val[0] != 0xDE)
    {
        [[BLTRealTime sharedInstance] saveRealTimeDataToDBAndUpdateUI:_realTimeData];
    }
}

#pragma mark --- syncData 数据清空 ---
- (void)cleanMutableData
{
    [_syncData resetBytesInRange:NSMakeRange(0, _syncData.length)];
    [_syncData setLength:0];
}

- (void)cleanMutableRealTimeData
{
    [_realTimeData resetBytesInRange:NSMakeRange(0, _realTimeData.length)];
    [_realTimeData setLength:0];
}

// 检查当次通讯是否发生错误
- (void)checkWhetherCommunicationError
{
    if (_type == BLTAcceptDataTypeUnKnown)
    {
        [self updateFailInfo];
    }
}

// 提示失败信息
- (void)updateFailInfo
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkWhetherCommunicationError) object:nil];

    NSLog(@" 提示失败信息");
    _type = BLTAcceptDataTypeError;
    if (_updateValue)
    {
        _updateValue(nil, _type);
        _updateValue = nil;
    }
}

@end

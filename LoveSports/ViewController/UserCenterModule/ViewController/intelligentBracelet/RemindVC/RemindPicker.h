//
//  RemindPicker.h
//  LoveSports
//
//  Created by zorro on 15/4/6.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindModel.h"

@interface RemindPicker : UIView

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIViewSimpleBlock cancelBlock;
@property (nonatomic, strong) UIViewSimpleBlock confirmBlock;

- (void)updateContentForDatePicker:(NSString *)time;

@end

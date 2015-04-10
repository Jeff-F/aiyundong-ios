//
//  AppDelegate.m
//  LoveSports
//
//  Created by zorro on 15-1-21.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "AppDelegate.h"
#import "MSIntroView.h"
#import "BraceletInfoModel.h"
#import "BLTManager.h"
#import "BLTAcceptData.h"
#import "DownloadEntity.h"
#import "BLTDFUBaseInfo.h"
#import "ViewController.h"
#import "UserInfoHelp.h"

@interface AppDelegate ()<EAIntroDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
   // 80770100 008d0200 00130000 009a0100 00000000

    [[DataShare sharedInstance] checkDeviceModel];

    // 启动蓝牙并自动接受数据
    [BLTAcceptData sharedInstance];
    [BLTRealTime sharedInstance];
    [self createVideoFloders];
    
    // 生成用户与最后使用过的手环
    [UserInfoHelp sharedInstance];
    
    [[DownloadEntity sharedInstance] downloadFileWithWebsite:DownLoadEntity_UpdateZip withRequestType:DownloadEntityRequestUpgradePatch];

    //添加默认数据
    [self addTestData];
    //添加信息完善页，如果已添加，直接进入主页
    if ((![[ObjectCTools shared] objectForKey:@"addVC"]))
    {
          [self addLoginView:YES];
       
    }
    else
    {
        [self pushToContentVC];
    }
    
    /*
     _vc = [HomeVC custom];
     self._mainNavigationController = [[UINavigationController alloc] initWithRootViewController: _vc];
     
     self.window.rootViewController = self._mainNavigationController;
     */
//    [self pushToContentVC];
    
    //导航条设置
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"1_01"] forBarMetrics:UIBarMetricsDefault];
    
    //修改导航条标题栏颜色
    [[UINavigationBar appearance] setBarTintColor: kNavigationBarColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    //按效果图的导航条只能设置成黑色，要么隐藏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //添加介绍页
    [self addIntroView];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)getUpdateFirmWareData
{
    [BLTDFUBaseInfo getUpdateFirmWareData];
}

- (void)createVideoFloders
{
    NSLog(@"..%@", [XYSandbox libCachePath]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[[XYSandbox libCachePath] stringByAppendingPathComponent:LS_FileCache_UpgradePatch] error:nil];
    
    [XYSandbox createDirectoryAtPath:[[XYSandbox libCachePath] stringByAppendingPathComponent:LS_FileCache_Others]];
    [XYSandbox createDirectoryAtPath:[[XYSandbox libCachePath] stringByAppendingPathComponent:LS_FileCache_UpgradePatch]];
    
    [XYSandbox createDirectoryAtPath:[[XYSandbox docPath] stringByAppendingPathComponent:@"/db/"]];
    [XYSandbox createDirectoryAtPath:[[XYSandbox docPath] stringByAppendingPathComponent:@"/dbimg/"]];
    
    // 通知不用上传备份
    [[[XYSandbox docPath] stringByAppendingPathComponent:@"/db/"] addSkipBackupAttributeToItem];
    [[[XYSandbox docPath] stringByAppendingPathComponent:@"/dbimg/"] addSkipBackupAttributeToItem];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 进入前台的时候蓝牙连接的话就同步.
    [[BLTSimpleSend sharedInstance] synHistoryDataEnterForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

#pragma mark ---------------- 介绍页 & 介绍页回调-----------------
//添加介绍页
- (void) addIntroView
{
    if (![[ObjectCTools shared] objectForKey:@"introViewShow"])
    {
        [MSIntroView initWithType: showIntroWithCrossDissolve rootView: self.window.rootViewController.view delegate: self];
    }
}

//介绍页完成回调
- (void) introDidFinish:(EAIntroView *)introView
{
    NSLog(@"介绍页加载完毕");
    [[ObjectCTools shared] setobject:[NSNumber numberWithInt:1] forKey:@"introViewShow"];
}


#pragma mark ---------------- 登录  &  退出-----------------
//准备去登录（包括持续登录校验）
- (void) readyToLogin: (BOOL) animated
{
    //token不显式保存
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoginUserInfoDictionaryKey];
    if (!userInfo)
    {
        [self addLoginView: animated];
    }
    else
    {
        NSLog(@"持续登录...");
        //持续登录
        //            println("持续登录token字典为== \(userToken)");
        //            println("将本地个人信息凭证发送服务器进行验证,通过后直接广播刷新所有用户相关信息，进入主页")
    }
}

/**
 @brief 添加登录页（用于非持续登录或退出当前用户后跳转回登录页）
 @param animated  BOOL: YES表示动画的形式添加，NO表示非动画形式添加
 */
- (void) addLoginView: (BOOL) animated
{
    NSLog(@"添加登录页面");
    [self pushToLoginVC];
}

/**
 @brief 注销登录
 */
- (void) signOut
{
    //先确保服务器退出，再本地退出
    [self localSignOut];
    
}


//本地退出
- (void) localSignOut
{
    [self addLoginView:YES];
}


#pragma mark ---------------- 测试数据构造---也作为默认本地用户数据构造  -----------------
- (void) addTestData
{
    
    //头像通过地址实时控制
    
    //     清除图片缓存：如果没有网络就用默认的
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [[ObjectCTools shared] refreshTheUserInfoDictionaryWithKey:kUserInfoOfHeadPhotoKey withValue:@"http://www.woyo.li/statics/users/avatar/46/thumbs/200_200_46.jpg?1422252425"];
    
    
    if (![[ObjectCTools shared] objectForKey:@"addTestDataForTest"])
    {
        [MSIntroView initWithType: showIntroWithCrossDissolve rootView: self.window.rootViewController.view delegate: self];
        
        //测试--给一个本地现在登录的测试用户信息
        NSDictionary *testUserInfoNow = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"http://www.woyo.li/statics/users/avatar/46/thumbs/200_200_46.jpg?1422252425", kUserInfoOfHeadPhotoKey,
                                         @"1990-01-01", kUserInfoOfAgeKey,
                                         @"亚洲/北京 (GMT+8) ", kUserInfoOfAreaKey,
                                         @"", kUserInfoOfDeclarationKey,
                                         @"172", kUserInfoOfHeightKey,
                                         @"75", kUserInfoOfStepLongKey,
                                         @"", kUserInfoOfInterestingKey,
                                         @"", kUserInfoOfNickNameKey,
                                         @"男", kUserInfoOfSexKey,
                                         @"62", kUserInfoOfWeightKey,
                                         @"1", kUserInfoOfIsMetricSystemKey,
                                         nil
                                         ];
        [[ObjectCTools shared] userAddUserInfo:testUserInfoNow];
        
       /*
        //测试--给另外2个曾经登录的测试用户信息
        NSDictionary *testUserInfo01 = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"http://www.woyo.li/statics/users/avatar/46/thumbs/200_200_46.jpg?1422252425", kUserInfoOfHeadPhotoKey,
                                        @"1989-06-06", kUserInfoOfAgeKey,
                                        @"广州 佛山", kUserInfoOfAreaKey,
                                        @"红雨漂泊泛起了回忆怎么浅...", kUserInfoOfDeclarationKey,
                                        @"168", kUserInfoOfHeightKey,
                                         @"42", kUserInfoOfStepLongKey,
                                        @"KTV", kUserInfoOfInterestingKey,
                                        @"关淑南", kUserInfoOfNickNameKey,
                                        @"女", kUserInfoOfSexKey,
                                        @"47", kUserInfoOfWeightKey,
                                         @"1", kUserInfoOfIsMetricSystemKey,
                                        nil
                                        ];
        
        
        NSDictionary *testUserInfo02 = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"http://www.woyo.li/statics/users/avatar/62/thumbs/200_200_62.jpg?1418642044", kUserInfoOfHeadPhotoKey,
                                        @"1977-01-01", kUserInfoOfAgeKey,
                                        @"少林寺", kUserInfoOfAreaKey,
                                        @"花开堪折直须折，莫待无花空折枝", kUserInfoOfDeclarationKey,
                                        @"172", kUserInfoOfHeightKey,
                                        @"48", kUserInfoOfStepLongKey,
                                        @"男", kUserInfoOfInterestingKey,
                                        @"大叔", kUserInfoOfNickNameKey,
                                        @"男", kUserInfoOfSexKey,
                                        @"66", kUserInfoOfWeightKey,
                                        @"1", kUserInfoOfIsMetricSystemKey,
                                        nil
                                        ];
        [[ObjectCTools shared] userAddUserInfo:testUserInfo02];
        [[ObjectCTools shared] userAddUserInfo:testUserInfo01];
        
//        //测试 添加 搜索到的设备 3 个
//        for (int i = 0; i < 3; i++)
//        {
//            BraceletInfoModel *oneBraceletInfoModel = [[BraceletInfoModel alloc] init];
//            //,版本号以及电量，设备id
//            oneBraceletInfoModel._deviceVersion = @"VB 1.01";
//            oneBraceletInfoModel._deviceElectricity = 0.85 / (i + 1.0);
//            oneBraceletInfoModel._deviceID = [NSString stringWithFormat:@"test000000000%d", i];
//            
//            //初始化后需要设置默认名等,并存入DB
//            [oneBraceletInfoModel setNameAndSaveToDB];
//        }
        
        */
        
        //只设置一次测试数据
        [[ObjectCTools shared] setobject:[NSNumber numberWithInt:1] forKey:@"addTestDataForTest"];
        
    }
    
    BraceletInfoModel *oneBraceletInfoModel = [[BraceletInfoModel alloc] init];
    //,版本号以及电量，设备id
    oneBraceletInfoModel._deviceVersion = @"VB 1.01";
    oneBraceletInfoModel._deviceElectricity = 0.85 / (1 + 1.0);
    oneBraceletInfoModel._deviceID = @"test0000000001324";
    
    //初始化后需要设置默认名等,并存入DB
    [oneBraceletInfoModel setNameAndSaveToDB];
    
}

- (void)pushToContentVC
{
    _vc = [HomeVC custom];
    self._mainNavigationController = [[ZKKNavigationController alloc] initWithRootViewController: _vc];
    
    self.window.rootViewController = self._mainNavigationController;
}

- (void)pushToLoginVC
{
//    LoginVC *login = [[LoginVC alloc] init];
//    ZKKNavigationController *nav = [[ZKKNavigationController alloc] initWithRootViewController: login];
//    
//    self.window.rootViewController = nav;
    
    
    ViewController *VC = [[ViewController alloc] init];
        ZKKNavigationController *nav = [[ZKKNavigationController alloc] initWithRootViewController: VC];
    //
        self.window.rootViewController = nav;
    
}

@end

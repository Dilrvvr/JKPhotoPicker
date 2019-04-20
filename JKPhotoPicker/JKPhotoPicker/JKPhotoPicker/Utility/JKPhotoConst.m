//
//  JKPhotoConst.m
//  JKPhotoPicker
//
//  Created by albert on 2019/4/20.
//  Copyright © 2019 安永博. All rights reserved.
//

#import "JKPhotoConst.h"
#import <AudioToolbox/AudioToolbox.h>


#pragma mark
#pragma mark - 适配

/// 是否X设备
BOOL JKPhotoIsDeviceX (void) {
    
    static BOOL JKPhotoIsDeviceX_ = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 11.0, *)) {
            
            if (!JKPlayerIsDeviceiPad()) {
                
                JKPhotoIsDeviceX_ = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom > 0;
            }
        }
    });
    
    return JKPhotoIsDeviceX_;
}

/// 是否iPad
BOOL JKPlayerIsDeviceiPad (void){
    
    static BOOL JKPlayerIsDeviceiPad_ = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (@available(iOS 11.0, *)) {
            
            JKPlayerIsDeviceiPad_ = [[UIDevice currentDevice].model isEqualToString:@"iPad"];
        }
    });
    
    return JKPlayerIsDeviceiPad_;
}

/// 当前是否横屏
BOOL JKPhotoIsLandscape (void) {
    
    return [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
}

/// 状态栏高度
CGFloat JKPhotoStatusBarHeight (void) {
    
    return JKPhotoIsDeviceX() ? 44.f : 20.f;
}

/// 导航条高度
CGFloat JKPhotoNavigationBarHeight (void) {
    
    return JKPhotoIsDeviceX() ? 88.f : 64.f;
}

/// tabBar高度
CGFloat JKPhotoTabBarHeight (void) {
    
    return (JKPhotoIsDeviceX() ? 83.f : 49.f);
}

/// X设备底部indicator高度
CGFloat const JKPhotoHomeIndicatorHeight = 34.f;

/// 当前设备底部indicator高度 非X为0
CGFloat JKPhotoCurrentHomeIndicatorHeight (void) {
    
    return JKPhotoIsDeviceX() ? 34.f : 0.f;
}

/// 使用KVC获取当前的状态栏的view
UIView * JKPhotoStatusBarView (void) {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    return statusBar;
}


/// 让手机振动一下
void JKPhotoCibrateDevice (void) {
    
    // 普通短震，3D Touch 中 Peek 震动反馈
    AudioServicesPlaySystemSound(1519);
    
    // 普通短震，3D Touch 中 Pop 震动反馈
    //AudioServicesPlaySystemSound(1520);
    
    // 连续三次短震
    //AudioServicesPlaySystemSound(1521);
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
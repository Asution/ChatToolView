//
//  ChatToolMacro.h
//  test
//
//  Created by 崔浩楠 on 2016/12/27.
//  Copyright © 2016年 chn. All rights reserved.
//

#ifndef ChatToolMacro_h
#define ChatToolMacro_h

#ifdef DEBUG
#   define CLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define CLog(...)
#endif

// self
#define WeakSelf typeof(self) __weak weakSelf = self;
#define StrongSelf typeof(weakSelf) __strong strongSelf = weakSelf;
#define StrongBySelf typeof(self) __strong strongSelf = self;


// device verson float
#define Current_System_Version [[[UIDevice currentDevice] systemVersion] floatValue]

// Size
#define Screen_Width  [[UIScreen mainScreen] bounds].size.width
#define Screen_Height [[UIScreen mainScreen] bounds].size.height

//相册图片的选择
#define Photo_Chat_List_Size CGSizeMake(117, 208)
//颜色
#define UIColorFromRGB(rgbValue, alph) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(alph)]

#define kVoiceRecorderTime 60.0 //max time
#define kVoiceRecorderLowTime 1.0 //max time

#define ResignFirstResponder \
UIWindow *window = [UIApplication sharedApplication].keyWindow;\
[window endEditing:YES];


#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif


#endif /* ChatToolMacro_h */

//
//  CCCameraManger.h
//  CustomCamera
//
//  Created by zhouke on 16/8/31.
//  Copyright © 2016年 All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+CCTool.h"

@interface CCCameraManger : NSObject

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) BOOL faceRecognition;
@property (nonatomic, copy) void(^getimageBlock)(UIImage *image);
@property (nonatomic, assign) BOOL isStartGetImage; // 是否开始从输出数据流捕捉单一图像帧

- (instancetype)initWithParentView:(UIView *)parent;

- (void)startUp;
// 开启闪光灯
- (void)openFlashLight;
// 关闭闪光灯
- (void)closeFlashLight;
// 切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
// 拍照
- (void)takePhotoWithImageBlock:(void(^)(UIImage *originImage,UIImage *scaledImage,UIImage *croppedImage))block;
// 对焦
- (void)focusInPoint:(CGPoint)devicePoint;


@end

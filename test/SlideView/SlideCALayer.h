//
//  SlideCALayer.h
//  test
//
//  Created by 崔浩楠 on 2017/3/14.
//  Copyright © 2017年 chn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface SlideCALayer : CALayer

/**
 *  CurveLayer的进度 0~1
 */
@property(nonatomic,assign)CGFloat progress;

@end

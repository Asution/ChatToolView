//
//  SlideView.h
//  test
//
//  Created by 崔浩楠 on 2017/3/14.
//  Copyright © 2017年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extend.h"



@interface SlideView : UIView
/**
 *  初始化方法
 *
 *  @param scrollView 关联的滚动视图
 *
 *  @return self
 */
-(id)initWithSlideScrollView:(UIScrollView *)scrollView titleAry:(NSArray *)titleAry;

@end

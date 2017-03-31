//
//  UIImageView+Extend.h
//  youplus
//
//  Created by 崔浩楠 on 2017/3/16.
//  Copyright © 2017年 YOU+. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extend)

//等比缩放
- (UIImage *) imageCompressForSize:(UIImage *)image maxSize:(CGFloat)maxSize;
@end

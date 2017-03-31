//
//  ImagesFlowLayout.m
//  test
//
//  Created by 崔浩楠 on 2016/12/22.
//  Copyright © 2016年 chn. All rights reserved.
//

#import "ImagesFlowLayout.h"

@implementation ImagesFlowLayout

- (instancetype) init {
    if (self = [super init]) {
        //设置水平滚动
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //间隔
        self.minimumLineSpacing = 0;

    }
    return self;
}


@end

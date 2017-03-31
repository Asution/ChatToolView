//
//  ChatToolView.h
//  test
//
//  Created by 崔浩楠 on 2016/12/21.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatToolView : UIView

- (instancetype)initWithImages:(NSArray *)images superView:(UIView *)superView;

@property (nonatomic, strong) NSMutableArray *imagesAry;

@end

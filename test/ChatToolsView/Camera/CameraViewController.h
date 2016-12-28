//
//  CameraViewController.h
//  test
//
//  Created by 崔浩楠 on 2016/12/23.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ToolsBtnClickBlock)(NSInteger type);

typedef NS_ENUM(NSInteger, ToolsBtnClickType) {
    ToolsBtnClickReplace = 0,
    ToolsBtnClickCancle ,
    ToolsBtnClickSend
};


@interface CameraViewController : UIViewController

@property (nonatomic , copy) ToolsBtnClickBlock block;

@end

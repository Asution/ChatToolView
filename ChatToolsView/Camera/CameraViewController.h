//
//  CameraViewController.h
//  test
//
//  Created by 崔浩楠 on 2016/12/23.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ToolsBtnClickType) {
    ToolsBtnClickReplace = 0,
    ToolsBtnClickCancle ,
    ToolsBtnClickSend
};

typedef void (^ToolsBtnClickBlock)(ToolsBtnClickType type, UIImage *image);


@interface CameraViewController : UIViewController

@property (nonatomic , copy) ToolsBtnClickBlock clickTypeBlock;

@end

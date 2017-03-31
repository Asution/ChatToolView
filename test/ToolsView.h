//
//  ToolsView.h
//  youplus
//
//  Created by 崔浩楠 on 2017/1/3.
//  Copyright © 2017年 guangzhou youplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolsModel : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSArray *operation;
@end


@interface ToolsView : UIView

- (instancetype)initWithModelAry:(NSArray *)modelAry;

@property (nonatomic, strong) NSArray *typeStrAry;
@end


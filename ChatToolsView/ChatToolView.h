//
//  ChatToolView.h
//
//  Created by 崔浩楠 on 2016/12/21.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extend.h"
#import "ChatToolMacro.h"
#import <BQMM/BQMM.h>

//不同类型的枚举
typedef NS_ENUM(NSInteger, ChatToolViewTypeEnum) {
    ChatToolViewTypeEnumVoice,
    ChatToolViewTypeEnumPhoto,
    ChatToolViewTypeEnumCamera,
    ChatToolViewTypeEnumEmoji,
    ChatToolViewTypeEnumRed
};


static const NSString *imageKey = @"toolImg";       //图片
static const NSString *toolTypeKey = @"toolType";   //按钮类型

@interface ToolBarBtn : UIButton

@property (assign, nonatomic) ChatToolViewTypeEnum typeEnum;

@end


@class ChatToolView;
@protocol ChatToolViewDelegate <NSObject>

@optional

// delegate style

//图片数组
- (void)sendImagsWithChatView:(ChatToolView *)chatToolView images:(NSArray *)images;
//语音  voicePath 路径 voiceDuration 时间
- (void)sendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration;

//发送表情  表情 model 文字
- (void)sendExpressionOrText:(MMEmoji *)emoji messageText:(NSString *)messageText;

//暂时还没有发送按钮
- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight isShowKeyBoard:(BOOL)isShowKeyBoard;
@end

@interface ChatToolView : UIView

@property (assign, nonatomic) ChatToolViewTypeEnum typeEnum;

//初始化方法，tool bar 的图片 ， 父view， frame
- (instancetype)initWithDataDictAry:(NSArray *)dictAry superView:(UIView *)superView frame:(CGRect)frame;

@property (nonatomic, strong) NSMutableArray *imagesAry;    //选中的image

@property (weak, nonatomic) id<ChatToolViewDelegate> toolViewDelegate;

@property (nonatomic, strong) UIViewController *superVc;

// block style
//发送图片 //暂时还没有发送按钮
@property (copy, nonatomic) void(^sendImagsBlock)(NSArray *images);

//发送语音
@property (copy, nonatomic) void(^sendMessageWithVoiceBlock)(NSString *voicePath, NSString *voiceDuration);

//发送表情 / 文字
@property (copy, nonatomic) void(^sendExpressionOrTextBlock)(MMEmoji *emoji, NSString *messageText);

//功能按钮点击4
@property (copy, nonatomic) void(^clickTypeBtnBlock)(ChatToolViewTypeEnum typeEnum);

//只显示输入框
- (void)showTextView;

@end

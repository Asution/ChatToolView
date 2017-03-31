//
//  ChatVoiceView.h
//  youplus
//
//  Created by 崔浩楠 on 2017/3/27.
//  Copyright © 2017年 YOU+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatVoiceView : UIView

@property (assign, nonatomic) CGRect superViewFrame;

/**
 *  是否正在錄音
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;

@property (copy, nonatomic) void(^sendMessageWithVoiceBlock)(NSString *voicePath, NSString *voiceDuration);

@end

//
//  ChatVoiceView.m
//  youplus
//
//  Created by 崔浩楠 on 2017/3/27.
//  Copyright © 2017年 YOU+. All rights reserved.
//

#import "ChatVoiceView.h"
#import "SCSiriWaveformView.h"
#import "ChatToolMacro.h"
#import "VoiceRecordManager.h"
#import "EMVoiceConverter.h"
#import "UIView+Extend.h"

@interface HighlightedButton : UIButton

@end

@implementation HighlightedButton

- (void)setHighlighted:(BOOL)highlighted{
    
}


@end


@interface ChatVoiceView()

@property (weak, nonatomic) IBOutlet UILabel *timesLabel;

@property (nonatomic, weak) IBOutlet SCSiriWaveformView *siriView;
@property (weak, nonatomic) IBOutlet HighlightedButton *voiceBtn;

@property (nonatomic, strong) VoiceRecordManager *voiceRecordManager;

@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;


/**  判断是不是超出了录音最大时长 */
@property (nonatomic) BOOL isMaxTimeStop;
/**
 *  是否取消錄音
 */
@property (nonatomic, assign, readwrite) BOOL isCancelled;

@property (assign, nonatomic) BOOL isChangeText;
@end

@implementation ChatVoiceView

- (VoiceRecordManager *)voiceRecordHelper {
    if (!_voiceRecordManager) {
        _isMaxTimeStop = NO;
        
        WeakSelf
        _voiceRecordManager = [[VoiceRecordManager alloc] init];
        _voiceRecordManager.maxTimeStopRecorderCompletion = ^{
            CLog(@"已经达到最大限制时间了，进入下一步的提示");
//            weakSelf.isVoiceTalking = NO;
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordManager.peakPowerForChannel = ^(float peakPowerForChannel) {
//            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordManager.maxRecordTime = kVoiceRecorderTime;
    }
    return _voiceRecordManager;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ChatVoiceView" owner:self options:nil] objectAtIndex:0];
        [self startUpdatingMeter];
    }
    
    return self;
}

-(void)startUpdatingMeter
{
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)stopUpdatingMeter
{
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = nil;
}

- (void)updateMeters
{
    [self.voiceRecordManager.recorder updateMeters];
    
    CGFloat normalizedValue = pow (10, [self.voiceRecordManager.recorder averagePowerForChannel:0] / 30);
    
    [self.siriView updateWithLevel:normalizedValue];
    
    if (self.voiceRecordManager.recorder.isRecording && self.isChangeText)
    {
        self.timesLabel.text = [NSString stringWithFormat:@"%.01fS",self.voiceRecordManager.recorder.currentTime];
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.width = Screen_Width;
    self.siriView.hidden = YES;
    self.siriView.superViewFrame = CGRectMake(0, 0, Screen_Width + 40, self.bounds.size.height);
    [self.voiceBtn addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.voiceBtn addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceBtn addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceBtn addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.voiceBtn addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
}

#pragma mark - 录音监听
- (void)holdDownButtonTouchDown {
    self.isCancelled = NO;
    self.isRecording = NO;
    
    [self prepareRecordingVoiceActionWithCompletion:^BOOL{
        StrongBySelf
        //這邊要判斷回調回來的時候, 使用者是不是已經早就鬆開手了
        if (strongSelf && !strongSelf.isCancelled) {
            strongSelf.isRecording = YES;
            [strongSelf startRecord];
            return YES;
        } else {
            return NO;
        }
    }];
    
}

- (void)holdDownButtonTouchUpOutside {
    if (self.isRecording) {
        [self cancelRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownButtonTouchUpInside {
    if (self.isRecording) {
        if (self.isMaxTimeStop == NO) {
            [self finishRecorded];
        } else {
            self.isMaxTimeStop = NO;
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragOutside {
    if (self.isRecording) {
        [self resumeRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragInside {
    if (self.isRecording) {
        [self pauseRecord];
       
    } else {
        self.isCancelled = YES;
    }
}

- (void)startRecord {
    [self startUpdatingMeter];
    self.siriView.hidden = NO;
    self.isChangeText = YES;
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}

- (void)finishRecorded {
    WeakSelf
    self.timesLabel.text = @"戳我肚纸发语音";
    [self.siriView changeColorIsDelete:NO];
    [self stopUpdatingMeter];
    self.siriView.hidden = YES;
    self.isRecording = NO;
    self.timesLabel.textColor = UIColorFromRGB(0x999999 , 1);
    [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_voice"] forState:UIControlStateNormal];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        [weakSelf didSendMessageWithVoice:weakSelf.voiceRecordHelper.recordPath voiceDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}

- (void)pauseRecord {
    [self.siriView changeColorIsDelete:NO];
    self.isChangeText = YES;
    self.timesLabel.text = [NSString stringWithFormat:@"%.0fS",self.voiceRecordManager.recorder.currentTime];
    self.timesLabel.textColor = UIColorFromRGB(0x999999 , 1);
    [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_voice"] forState:UIControlStateNormal];
}

- (void)resumeRecord {
    [self.siriView changeColorIsDelete:YES];
    self.isChangeText = NO;
    self.timesLabel.text = @"手指上滑，取消发送";
    self.timesLabel.textColor = UIColorFromRGB(0xFF4563 , 1);
    [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_voice_delete"] forState:UIControlStateNormal];

}

- (void)cancelRecord {
    [self.siriView changeColorIsDelete:NO];
    self.timesLabel.text = @"戳我肚纸发语音";
    [self stopUpdatingMeter];
    self.timesLabel.textColor = UIColorFromRGB(0x999999 , 1);
    self.isRecording = NO;
    [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_voice"] forState:UIControlStateNormal];

    self.siriView.hidden = YES;
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}

- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
//    CLog(@"prepareRecordingWithCompletion");
    [self prepareRecordWithCompletion:completion];
}

- (void)prepareRecordWithCompletion:(XHPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}

#pragma mark - 获取语音路径
- (NSString *)getRecorderPath {
    
    NSString *recorderPath = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *dataStr = [dateFormatter stringFromDate:now];
    
    recorderPath = [NSString stringWithFormat:@"%@/voice/",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:recorderPath withIntermediateDirectories:YES attributes:nil error:nil];
    recorderPath = [recorderPath stringByAppendingFormat:@"%@.wav", dataStr];
    
    return recorderPath;
}

#pragma mark - 语音路径
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    CLog(@"send voicePath : %@", voicePath);
    
    if (voicePath) {
        // Convert wav to amr
        NSString *amrFilePath = [[voicePath stringByDeletingPathExtension]
                                 stringByAppendingPathExtension:@"amr"];
        BOOL convertResult = [self convertWAV:voicePath toAMR:amrFilePath];
        //        NSError *error = nil;
        if (convertResult) {
            // Remove the wav
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:voicePath error:nil];
        }
//        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:amrFilePath] fileTypeHint:nil error:nil];
        
        if([voiceDuration floatValue] < kVoiceRecorderLowTime){
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:amrFilePath error:nil];
        }else{
            self.sendMessageWithVoiceBlock != nil ? self.sendMessageWithVoiceBlock(amrFilePath, voiceDuration) : nil;
        }
    }
}

- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [EMVoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (!isFileExists) {
            
        } else {
            ret = YES;
        }
    }
    
    return ret;
}


@end

//
//  ChatToolView.m
//  test
//
//  Created by 崔浩楠 on 2016/12/21.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ChatToolView.h"
#import "UIView+Extend.h"
#pragma mark - 相册
#import <Photos/Photos.h>
#import "ImagesFlowLayout.h"
#import "ImagesChooseCell.h"
#import "MomentDataSource.h"
#import "ImageDataAPI.h"
#pragma mark - 相机
#import "CameraViewController.h"
#pragma mark - define
#import "ChatToolMacro.h"
#pragma mark - 语音
#import "VoiceRecordHUD.h"
#import "VoiceRecordManager.h"
#pragma mark - 输入框
#import "MessageTextView.h"

static NSString *const placeHolderStr = @"请输入聊天内容...";

static NSInteger const functionViewY = 49.5 + 43;   //输入框 + 功能按钮 高度

@interface ChatToolView() <UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic , weak) UIButton *albumBtn;    //相册按钮

@property (nonatomic , weak) UIView *functionView;  //工具栏选项bg view

@property (nonatomic, weak)  UIActivityIndicatorView *idView;

@property (nonatomic, strong) ImagesFlowLayout *flowLayout; //collection view layout

@property (nonatomic, strong) MomentDataSource *dataSource;

@property (nonatomic, strong) NSMutableArray *backupArr;
@property (nonatomic, strong) NSMutableArray *imagesSelectedIndexAry;
@property (assign, nonatomic) NSInteger currentCount;

@property (nonatomic, strong) UIViewController *superVc;

@property (nonatomic, strong) VoiceRecordHUD *voiceRecordHUD;
@property (nonatomic, strong) VoiceRecordManager *voiceRecordManager;
@property (nonatomic , weak) UIView *talkView;  //聊天按钮 bg view

@property (nonatomic , weak) UIView *lineView;  //线
@property (nonatomic , weak) MessageTextView *messageTextView;

@property (assign, nonatomic) CGFloat keyboardY;

@property (nonatomic , assign) BOOL isTalking;  //是否正在聊天

/**  判断是不是超出了录音最大时长 */
@property (nonatomic) BOOL isMaxTimeStop;
/**
 *  是否取消錄音
 */
@property (nonatomic, assign, readwrite) BOOL isCancelled;

/**
 *  是否正在錄音
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;

/**
 *  根据录音路径开始发送语音消息
 *
 *  @param voicePath        目标语音路径
 *  @param voiceDuration    目标语音时长
 */
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration;

@end

@implementation ChatToolView
{
    dispatch_queue_t serialPGQueue;

}

- (instancetype)initWithImages:(NSArray *)images superView:(UIView *)superView{
    self = [super init];
    if (self) {
        self.imagesAry = [NSMutableArray array];
        self.imagesSelectedIndexAry = [NSMutableArray array];
        
        serialPGQueue = dispatch_queue_create("com.haonan", DISPATCH_QUEUE_SERIAL);
        
        [self initSubViewsWithImages:images];
        [self initCollectioView];
        [self initChooseImages];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

        [superView addSubview:self];
        
        self.superVc = [self getCurrentViewController];
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 监听键盘的改变
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    //1. 获取键盘的 Y 值
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyboardFrame.origin.y;
    self.keyboardY = keyboardY;
}

-(UIViewController *)getCurrentViewController{
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponser = [next nextResponder];
        if ([nextResponser isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponser;
        }
    }
    return nil;
}

- (void)initChooseImages{
    
    CellConfigureBlock configureCell = ^(ImagesChooseCell *cell, id asset)
    {
        NSInteger cTag = cell.tag; // to determin if cell is reused
        
        [[ImageDataAPI sharedInstance] getThumbnailForAssetObj:asset
                                                      withSize:Photo_Chat_List_Size
                                                    completion:^(BOOL ret, UIImage *image)
         {
             if (cell.tag == cTag) [cell configureForImage:image];
             [cell setSelectedWithAry:self.imagesSelectedIndexAry];
         }];
        
        cell.block = ^(ImagesChooseCell *cell, NSNumber *tag, BOOL selected){
            
            for (int i = 0; i < self.imagesAry.count; i++) {
                NSData *data = UIImageJPEGRepresentation(cell.imageView.image, 1.0);
                NSData *data2 = UIImageJPEGRepresentation(self.imagesAry[i], 1.0);
                if ([data isEqual:data2]) {
                    [self.imagesAry removeObjectAtIndex:i];
                }
            }
            
            if(selected && ![self.dataSource checkHaveTagWithAry:self.imagesSelectedIndexAry tag:tag]){
                
                [self.imagesAry addObject:cell.imageView.image];
                
                self.currentCount ++;
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:@(self.currentCount) forKey:[NSString stringWithFormat:@"%@",tag]];
                [self.imagesSelectedIndexAry addObject:dict];
            }else{
                self.currentCount --;
                self.imagesSelectedIndexAry = [self.dataSource setSelectedAryAndUpdateCount:self.imagesSelectedIndexAry tag:tag];
            }
            [cell setSelectedWithAry:self.imagesSelectedIndexAry];
            [self.collectionView reloadData];
        };
    };
    
    MomentDataSource *pDataSource = [[MomentDataSource alloc] initWithCellIdentifier:@"ImagesChooseCell" configureCellBlock:configureCell];
    
    self.collectionView.dataSource = pDataSource; [self setDataSource:pDataSource];
    
    if ([[ImageDataAPI sharedInstance] haveAccessToPhotos]) [self loadMomentElementsShowIndicatorView:NO];
}

#pragma mark - 加载数据
- (void)loadMomentElementsShowIndicatorView:(BOOL)show
{
    if(show) [self showIndicatorView];
    
    dispatch_async(serialPGQueue, ^
                   {
                       [[ImageDataAPI sharedInstance] getMomentsWithBatchReturn:YES
                                                                      ascending:NO
                                                                     completion:^(BOOL done, id obj)
                        {
                            NSMutableArray *dArr = (NSMutableArray *)obj;
                            
                            if (dArr != nil && [dArr count])
                            {
                                if (!self.collectionView.dragging && !self.collectionView.decelerating)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       if (done) {[self hideIndicatorView];[self reloadWithData:dArr];}
                                                   });
                                }
                                else
                                {
                                    if (done) {self.backupArr = dArr; [self hideIndicatorView]; }
                                }
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(), ^
                                               {
                                                   if (done) {[self hideIndicatorView];}
                                               });
                            }
                        }];
                   });
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && self.backupArr)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadWithData:self.backupArr];
            self.backupArr = nil; // done refresh
        });
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.backupArr)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadWithData:self.backupArr];
            self.backupArr = nil; // done refresh
        });
    }
}

#pragma mark - Reload CollectView
- (void)reloadWithData:(NSMutableArray *)data
{
    [self.dataSource.items removeAllObjects];
    [self.dataSource.items addObjectsFromArray:data];
    [self.collectionView reloadData]; [data removeAllObjects];
}


- (void)initCollectioView{
    self.flowLayout = [[ImagesFlowLayout alloc] init];
    
    CGRect rct = self.bounds;
    rct.size.height = 208.0f;
    rct.origin.y = functionViewY;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rct collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.hidden = YES;   //暂时隐藏
    
    UINib *cellNib = [UINib nibWithNibName:@"ImagesChooseCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:NSStringFromClass([ImagesChooseCell class])];

    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    
    [self addSubview:_collectionView];
}

#pragma mark - UIActivityIndicatorView
- (void)showIndicatorView
{
    [self.idView setHidden:NO]; [self.idView startAnimating];
}
    
- (void)hideIndicatorView
{
    [self.idView stopAnimating]; [self.idView setHidden:YES];
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(123.5, 208);
}

#pragma mark - 调用相机功能
- (void)openCamera{
    if(![self authorizationCamera]) return;
    
    CameraViewController *vc = [[CameraViewController alloc] init];
    [self.superVc presentViewController:vc animated:YES completion:nil];
}

- (BOOL)authorizationCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"不支持/未授权");
        //未授权
        return NO;
    }
    
    return YES;
}

#pragma mark - 语音

- (VoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[VoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}

- (void)startRecord {
    [self.voiceRecordHUD startRecordingHUDAtView:self.superview];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}

- (void)finishRecorded {
    WeakSelf
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        [weakSelf didSendMessageWithVoice:weakSelf.voiceRecordHelper.recordPath voiceDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}

- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

- (void)cancelRecord {
    WeakSelf
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}

#pragma mark - 语音路径
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    CLog(@"send voicePath : %@", voicePath);
//    if ([self.delegate respondsToSelector:@selector(didSendVoice:voiceDuration:fromSender:onDate:)]) {
//        [self.delegate didSendVoice:voicePath voiceDuration:voiceDuration fromSender:self.messageSender onDate:[NSDate date]];
//    }
}


- (VoiceRecordManager *)voiceRecordHelper {
    if (!_voiceRecordManager) {
        _isMaxTimeStop = NO;
       
        WeakSelf
        _voiceRecordManager = [[VoiceRecordManager alloc] init];
        _voiceRecordManager.maxTimeStopRecorderCompletion = ^{
            CLog(@"已经达到最大限制时间了，进入下一步的提示");
            weakSelf.isTalking = NO;
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordManager.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordManager.maxRecordTime = kVoiceRecorderTime;
    }
    return _voiceRecordManager;
}


#pragma mark - 初始化一些功能

#pragma mark - button delegate
#pragma mark - 功能选择
- (void)btnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    ResignFirstResponder
    [self hideIndicatorView];
    switch (btn.tag) {
        case 0: //相册
            self.talkView.hidden = YES;                             //隐藏语音按钮
            self.albumBtn.hidden = NO;                              //进入相册
            self.collectionView.hidden = NO;                        //显示照片列表
            self.messageTextView.hidden = NO;                       //显示输入框
            self.isTalking = NO;                                    //语音输入
            [self loadMomentElementsShowIndicatorView:YES];         //记载数据
            [self bringSubviewToFront:self.albumBtn];               //将view放入最前面
            [self bringSubviewToFront:self.idView];
            self.lineView.y = 0;
            self.messageTextView.y = 10;
            self.height = self.collectionView.height + self.messageTextView.height + 49.5 + 10;
            self.y = Screen_Height - self.height;
            self.functionView.y = self.messageTextView.height + 11;
            self.collectionView.y = self.messageTextView.height + 1 + 49.5 + 10;
            self.albumBtn.y = self.messageTextView.height + 10 + 49.5 + 158;
            break;
            
        case 1: //相机
            self.isTalking = NO;
            [self openCamera];
            break;
            
        case 2: //语音
            if(self.isTalking){ //文字输入
                self.isTalking = NO;
//                [self.messageTextView becomeFirstResponder];
                [self hiddenAllFunction];
                self.height = self.messageTextView.height + 49.5 + 20;
                self.y = Screen_Height - self.height;
                self.functionView.y = self.messageTextView.height + 10;
                self.lineView.y = 0;
            }else{  //语音输入
                self.isTalking = YES;
                self.talkView.hidden = NO;
                self.albumBtn.hidden = YES;
                self.collectionView.hidden = YES;
                self.messageTextView.hidden = YES;
                self.lineView.y = 0;
                self.functionView.y = 0.5;
                self.talkView.y = 50;
                self.y = Screen_Height - 50 - 65;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - 相册按钮
- (void)albumBtnClick:(UIButton *)btn{
    NSLog(@"album %s",__FUNCTION__);
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
    
    //如果已經開始錄音了, 才需要做取消的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self cancelRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownButtonTouchUpInside {
    
    //如果已經開始錄音了, 才需要做結束的動作, 否則只要切換 isCancelled, 不讓錄音開始.
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
    
    //如果已經開始錄音了, 才需要做拖曳出去的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self resumeRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragInside {
    
    //如果已經開始錄音了, 才需要做拖曳回來的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self pauseRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    CLog(@"prepareRecordingWithCompletion");
    [self prepareRecordWithCompletion:completion];
}

- (void)prepareRecordWithCompletion:(XHPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}

#pragma mark - 获取语音路径
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.m4a", [dateFormatter stringFromDate:now]];
    return recorderPath;
}

#pragma mark - init tools button
- (void)initSubViewsWithImages:(NSArray *)images{
    UIView *functionView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, Screen_Width, 49.5)];
    self.functionView = functionView;

    for (int i = 0; i < images.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnW = [UIScreen mainScreen].bounds.size.width * 0.2;
        CGFloat btnH = 49.5f;
        CGFloat btnX = i * btnW;
        CGFloat btnY = 0;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        if ([images[i] isKindOfClass:[UIImage class]]) {
            [btn setImage:images[i] forState:UIControlStateNormal];
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [functionView addSubview:btn];
    }
    [self addSubview:functionView];
    
    //加载相册的菊花
    UIActivityIndicatorView *idView = [[UIActivityIndicatorView alloc] init];
    idView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5 - 22.5, 80, 45, 45);
    idView.color = [UIColor grayColor];
    self.idView = idView;
    [self addSubview:idView];
    
    //显示相册按钮
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(15, self.messageTextView.height + 49.6 + 20 + 158, 35, 35);
    albumBtn.hidden = YES;
    albumBtn.backgroundColor = [UIColor redColor];
    [albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.albumBtn = albumBtn;
//    [self addSubview:albumBtn];
    
    //说话按钮bg view
    UIView *talkView = [[UIView alloc] initWithFrame:CGRectMake(0, functionViewY, Screen_Width, 65)];    //聊天bg view
    self.talkView = talkView;
    [self addSubview:talkView];
    self.talkView.hidden = YES; //暂时隐藏
    
    //按住说话按钮
    UIButton *talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    talkBtn.frame = CGRectMake(20, 0, Screen_Width - 40, 45);
    [talkView addSubview:talkBtn];
    
    talkBtn.backgroundColor = UIColorFromRGB(0xffe362, 1);
    talkBtn.layer.cornerRadius = 5;
    talkBtn.layer.masksToBounds = YES;
    talkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [talkBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [talkBtn setTitleColor:UIColorFromRGB(0x5a5858, 1) forState:UIControlStateNormal];
    
    [talkBtn addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [talkBtn addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [talkBtn addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [talkBtn addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [talkBtn addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    //输入框
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0.5)];
    self.lineView = lineView;
    lineView.backgroundColor = UIColorFromRGB(0xd1d1d1, 1);
    [self addSubview:lineView];
    
    MessageTextView *messageTextView = [[MessageTextView alloc] initWithFrame:CGRectMake(10, 10, Screen_Width - 20, 33)];
    messageTextView.placeHolder = placeHolderStr;
    messageTextView.placeHolderTextColor = UIColorFromRGB(0xC1BDBB,1);
    self.messageTextView = messageTextView;
    [self addSubview:messageTextView];
    
    messageTextView.block = ^(CGFloat maxTextHeight, NSString *text, BOOL isChange){
        
        [self hiddenAllFunction];
        if(maxTextHeight <= 120){
            self.messageTextView.height = maxTextHeight;
            self.messageTextView.y = 10;
            self.lineView.y = 0;
            self.functionView.y = maxTextHeight + 10;
            self.height = 59.5 + maxTextHeight;
        }else{
            self.messageTextView.height = 120;
            self.height = 130 + 49.5;
            self.functionView.y = 130;
        }
        self.y = self.keyboardY - self.height;
    };
    
}

#pragma mark - 隐藏所有功能,回到最初状态
- (void)hiddenAllFunction{
    [self hideIndicatorView];
    self.albumBtn.hidden = YES;                     //相册库隐藏
    self.collectionView.hidden = YES;               //相册隐藏
    self.talkView.hidden = YES;                     //语音按钮隐藏
    self.messageTextView.hidden = NO;               //文字输show
}

@end

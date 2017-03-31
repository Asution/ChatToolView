//
//  ChatToolView.m
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

#pragma mark - 表情云
//#import <BQMM/BQMM.h>

//#import "EMCDDeviceManager+Media.h"
//#import "EMVoiceConverter.h"

#pragma mark - 语音输入
#import "ChatVoiceView.h"

#import "TZImagePickerController.h"

#import "TBCityIconFont.h"

@implementation ToolBarBtn

@end

static NSInteger const haveNav = 0;

static NSString *const placeHolderStr = @"请输入聊天内容...";

static NSInteger const functionViewY = 55 + 43;   //输入框 + 功能按钮 高度

@interface ChatToolView() <UICollectionViewDelegate, MMEmotionCentreDelegate, UITextViewDelegate, TZImagePickerControllerDelegate>

@property (nonatomic , weak) UIView *chooseImagesView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic , weak) UIButton *albumBtn;    //相册按钮
@property (nonatomic , weak) UIButton *sendImgsBtn;

@property (nonatomic , weak) UIView *functionView;  //工具栏选项bg view

@property (nonatomic, weak)  UIActivityIndicatorView *idView;

@property (nonatomic, strong) ImagesFlowLayout *flowLayout; //collection view layout

@property (nonatomic, strong) MomentDataSource *dataSource;

@property (nonatomic, strong) NSMutableArray *backupArr;
@property (nonatomic, strong) NSMutableArray *imagesSelectedIndexAry;
@property (nonatomic, strong) NSMutableArray *sendImagesAsset;
@property (assign, nonatomic) NSInteger currentCount;

@property (nonatomic, strong) VoiceRecordHUD *voiceRecordHUD;
//@property (nonatomic, strong) VoiceRecordManager *voiceRecordManager;
@property (nonatomic , weak) UIView *talkView;  //聊天按钮 bg view

@property (nonatomic , weak) UIView *lineView;  //线
@property (nonatomic , weak) MessageTextView *messageTextView;

@property (assign, nonatomic) CGFloat keyboardY;

@property (nonatomic, assign) BOOL isVoiceTalking;  //是否正在语音聊天
@property (assign, nonatomic) BOOL isShowExpression; //显示表情键盘
@property (assign, nonatomic) BOOL isShowKeyBoard;

@property (assign, nonatomic) CGFloat keyBoardHeigth;   //键盘高度

@property (assign, nonatomic) CGFloat keyBoderAdimationDuration; //键盘动画时间
@property (nonatomic , assign) UIViewAnimationCurve curve;

@property (nonatomic , weak) ChatVoiceView *voiceView;

@property (nonatomic, strong) NSMutableArray *photoLibaryAry;

@end

@implementation ChatToolView
{
    dispatch_queue_t serialPGQueue;

}

- (instancetype)initWithDataDictAry:(NSArray *)dictAry superView:(UIView *)superView frame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.imagesAry = [NSMutableArray array];
        self.imagesSelectedIndexAry = [NSMutableArray array];
        self.photoLibaryAry = [NSMutableArray array];
        self.sendImagesAsset = [NSMutableArray array];
        serialPGQueue = dispatch_queue_create("com.haonan", DISPATCH_QUEUE_SERIAL);
        
        [self initSubViewsWithDataDictAry:dictAry];
        [self initChooseImagesView];     //选择图片view
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
        
        if(!superView){
            [superView addSubview:self];
        }
        
        self.superVc = [self getCurrentViewController];
        
    }
    return self;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码

        [self sendMessageWithEmoji:nil messageText:self.messageTextView.text];
        self.messageTextView.text = nil;
        
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

#pragma mark - 监听键盘的改变
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    //1. 获取键盘的 Y 值
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.keyBoardHeigth = endFrame.size.height;
    
    self.keyBoderAdimationDuration = duration;
    self.curve = curve;
    
    void(^animations)() = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [self aboutKeyBoderAnimationWithBlock:animations curve:curve];
    
    self.keyboardY = endFrame.origin.y;
}

- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self _willShowBottomHeight:toFrame.size.height];
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        self.isShowKeyBoard = NO;
        [self _willShowBottomHeight:0];
    }
    else{
        [self _willShowBottomHeight:toFrame.size.height];
    }
}

//跟键盘有关的动画
- (void)aboutKeyBoderAnimationWithBlock:(void (^)())animations curve:(UIViewAnimationCurve)curve{
    [UIView animateWithDuration:self.keyBoderAdimationDuration + self.keyBoderAdimationDuration * 0.1 delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}


/*!
 @method
 @brief 调整toolBar的高度
 @param bottomHeight 底部菜单的高度 */

- (void)_willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, Screen_Height - bottomHeight - fromFrame.size.height, fromFrame.size.width, self.height);
    self.frame = toFrame;
    if(bottomHeight == 0){
        self.y = Screen_Height - functionViewY - haveNav;
        self.functionView.y = 43.0f;
    }
}

#pragma 返回当前控件占用的高度，用来调节外部tableview / scrollview 滚动
- (void)returnSelfHeight{
    CGFloat changeHeight = functionViewY; //默认高度
    
    if(!self.chooseImagesView.hidden && !self.isShowKeyBoard){ //图片选择功能
        changeHeight = functionViewY + self.chooseImagesView.height;
        
    }else if (self.isShowExpression || self.isShowKeyBoard){ //表情功能 / 键盘显示
        changeHeight = self.height + self.keyBoardHeigth;
        
    }else if (self.isVoiceTalking){   //录音功能
        changeHeight = 50 + 200;
        
    }else if (self.keyboardY < Screen_Height && self.keyboardY > 0){
        changeHeight = functionViewY + Screen_Height - self.keyboardY;
        
    }else {
        changeHeight = functionViewY;
    }
    
    if ([self.toolViewDelegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:isShowKeyBoard:)]) {
        [self.toolViewDelegate chatToolbarDidChangeFrameToHeight:changeHeight isShowKeyBoard:self.isShowKeyBoard];
    }
}


#pragma mark - 获取当前控制器
-(UIViewController *)getCurrentViewController{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (void)initChooseImages{
    //回调block 处理
    CellConfigureBlock configureCell = ^(ImagesChooseCell *cell, id asset, NSIndexPath *indexPath)
    {
        NSInteger cTag = cell.tag; // to determin if cell is reused

        [[ImageDataAPI sharedInstance] getThumbnailForAssetObj:asset
                                                      withSize:Photo_Chat_List_Size
                                                    completion:^(BOOL ret, UIImage *image2)
         {
             if (cell.tag == cTag) {
                 [cell configureForImage:image2];
             }
             cell.asset = asset;
             [cell setSelectedWithAry:self.imagesSelectedIndexAry];
             cell.indexPath = indexPath;
         }];

    
        cell.imageClickBlock = ^(ImagesChooseCell *cell, NSNumber *tag, BOOL selected, NSIndexPath *indexPath, id asset){
            
            for (int i = 0; i < self.imagesAry.count; i++) {
                NSData *data = UIImageJPEGRepresentation(cell.imageView.image, 1.0);
                NSData *data2 = UIImageJPEGRepresentation(self.imagesAry[i], 1.0);
                if ([data isEqual:data2]) {
                    [self.imagesAry removeObjectAtIndex:i];
                }
            }
            
            if(selected && ![self.dataSource checkHaveTagWithAry:self.imagesSelectedIndexAry tag:tag]){
                if(cell.imageView.image)
                    [self.imagesAry addObject:cell.imageView.image];
                
                self.currentCount ++;
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:@(self.currentCount) forKey:[NSString stringWithFormat:@"%@",tag]];
                [self.imagesSelectedIndexAry addObject:dict];
                
                if(asset)
                   [self.sendImagesAsset addObject:asset];
            }else{
                self.currentCount --;
                self.imagesSelectedIndexAry = [self.dataSource setSelectedAryAndUpdateCount:self.imagesSelectedIndexAry tag:tag];
                
                if(asset)
                   [self.sendImagesAsset removeObject:asset];
            }
            [cell setSelectedWithAry:self.imagesSelectedIndexAry];
            [self.collectionView reloadData];
        };
    };
    
    //collectionView 赋值
    MomentDataSource *pDataSource = [[MomentDataSource alloc] initWithCellIdentifier:@"ImagesChooseCell" configureCellBlock:configureCell];
    
    self.collectionView.dataSource = pDataSource; [self setDataSource:pDataSource];
    
    if ([[ImageDataAPI sharedInstance] haveAccessToPhotos]) [self loadMomentElementsShowIndicatorView:NO];
}

- (void)resetCollectionView{
    self.currentCount = 0;
    [self.imagesAry removeAllObjects];
    [self.imagesSelectedIndexAry removeAllObjects];
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
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

- (void)returnKeyBoardHidden{
    
}

- (void)initChooseImagesView{
    UIView *chooseImagesView = [[UIView alloc] initWithFrame:CGRectMake(0, 94, Screen_Width, 200)];
    self.chooseImagesView = chooseImagesView;
    [self addSubview:chooseImagesView];
    self.flowLayout = [[ImagesFlowLayout alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnKeyBoardHidden)];
    [chooseImagesView addGestureRecognizer:tap];
    
    CGRect rct = self.bounds;
    rct.size.height = 147.0f;
    rct.origin.y = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rct collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.chooseImagesView.hidden = YES;   //暂时隐藏
    
    UINib *cellNib = [UINib nibWithNibName:@"ImagesChooseCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:NSStringFromClass([ImagesChooseCell class])];

    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    
    [self.chooseImagesView addSubview:_collectionView];
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
    return CGSizeMake(110, 147);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}
#pragma mark - 调用相机功能
- (void)openCamera{
//    if(![self authorizationCamera]) return;
    self.isVoiceTalking = NO;
    CameraViewController *vc = [[CameraViewController alloc] init];
    vc.clickTypeBlock = ^(ToolsBtnClickType type, UIImage *image){
        if (image) {
            _sendImagsBlock ? _sendImagsBlock(@[image]) : nil;
        }
    };
    [self.superVc presentViewController:vc animated:YES completion:nil];
}

- (BOOL)authorizationCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"不支持/未授权");
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        //未授权
        return NO;
    }
    
    return YES;
}


#pragma mark - 初始化一些功能

#pragma mark - show text view
- (void)showTextView{
    [self hiddenAllFunction];
    self.height = functionViewY + 20;
    self.y = Screen_Height - self.height;
    self.functionView.y = self.messageTextView.height + 10;
    self.lineView.y = 0;
    [self.messageTextView becomeFirstResponder];
}

#pragma mark - button delegate
#pragma mark - 功能选择
- (void)toolBtnClick:(ToolBarBtn *)btn{
    btn.selected = !btn.selected;
    
    [self hideIndicatorView];
    
    //显示相册的block animation
    void(^showPhotoLibraryAnimations)() = ^{
        [self showPhotoLibrary:btn];
    };
    
    //显示语音的block animation
    void(^showVoiceAnimations)() = ^{
        [self showVoice:btn];
    };
    
    BOOL cleanChooseImgs = NO;
    switch (btn.typeEnum) {
        case ChatToolViewTypeEnumPhoto: //相册
            [self setNormalImage];
            cleanChooseImgs = YES;
            [self aboutKeyBoderAnimationWithBlock:showPhotoLibraryAnimations curve:self.curve];
            
            break;
            
        case ChatToolViewTypeEnumCamera: //相机
            cleanChooseImgs = YES;
            [self resignFirstResponderForView];
            if(!SIMULATOR)
                [self openCamera];
            else
                NSLog(@"模拟器不支持相机功能");
            
            if(self.isShowExpression){
                self.isShowExpression = NO;
                [self setNormalImage];
            }
            break;
            
        case ChatToolViewTypeEnumVoice: //语音
            [self setNormalImage];
            cleanChooseImgs = YES;
            [self aboutKeyBoderAnimationWithBlock:showVoiceAnimations curve:self.curve];
            
            break;
            
        case ChatToolViewTypeEnumEmoji: //表情
            [self setNormalImage];
            cleanChooseImgs = YES;
            
            [self showExpression:btn];
            break;
            
        case ChatToolViewTypeEnumRed:
            cleanChooseImgs = NO;
            [self resignFirstResponderForView];
            
            if(self.isShowExpression){
                self.isShowExpression = NO;
                [self setNormalImage];
            }
            
            break;
        default:
            break;
    }
    //清空图片的选择
    if(cleanChooseImgs)
        [self resetCollectionView];
    //返回当前控件所占用的高度
    [self returnSelfHeight];
    
    self.clickTypeBtnBlock ? self.clickTypeBtnBlock(btn.typeEnum) : nil;
}

- (void)setNormalImage{
    
    for (int i = 0; i < self.functionView.subviews.count; i++) {
        UIScrollView *scView = nil;
        if ([self.functionView.subviews[i] isKindOfClass:[UIScrollView class]]) {
            scView = self.functionView.subviews[i];
        }
        if (scView){
            for (int j = 0; j < scView.subviews.count; j++) {
                ToolBarBtn *btn = nil;
                if([scView.subviews[j] isKindOfClass:[ToolBarBtn class]]){
                    btn = scView.subviews[j];
                    btn.selected = NO;
                    if (btn.typeEnum == ChatToolViewTypeEnumVoice) {
                        [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66e", 30, UIColorFromRGB(0xd8d8d8, 1))] forState:UIControlStateNormal];
                    }
                    if (btn.typeEnum == ChatToolViewTypeEnumPhoto) {
                        [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66d", 30, UIColorFromRGB(0xd8d8d8, 1))] forState:UIControlStateNormal];
                    }
                    if (btn.typeEnum == ChatToolViewTypeEnumCamera) {
                        [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66c", 30, UIColorFromRGB(0xd8d8d8, 1))] forState:UIControlStateNormal];

                    }
                    if (btn.typeEnum == ChatToolViewTypeEnumEmoji) {
                        [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66a", 30, UIColorFromRGB(0xd8d8d8, 1))] forState:UIControlStateNormal];

                    }
                    if (btn.typeEnum == ChatToolViewTypeEnumRed) {
                        [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66b", 30, UIColorFromRGB(0xd8d8d8, 1))] forState:UIControlStateNormal];

                    }
                }
            }
        }
    }
}

- (void)resignFirstResponderForView
{
    ResignFirstResponder
}

#pragma mark - expression
#pragma mark - toolbar show expression
// 点击发送表情
- (void)didSelectEmoji:(nonnull MMEmoji *)emoji
{
    [self sendMessageWithEmoji:emoji messageText:nil];
}

// 点击发送提示表情
- (void)didSelectTipEmoji:(nonnull MMEmoji *)emoji
{
    [self sendMessageWithEmoji:emoji messageText:nil];
}

- (void)didSendWithInput:(nonnull UIResponder<UITextInput> *)input{
    
    [self sendMessageWithEmoji:nil messageText:self.messageTextView.text];
    self.messageTextView.text = @"";
}

- (void)tapOverlay{
    
}

- (void)sendMessageWithEmoji:(MMEmoji *)emoji messageText:(NSString *)messageText{
    self.sendExpressionOrTextBlock ? self.sendExpressionOrTextBlock(emoji, self.messageTextView.text) : nil;
    
    if([self.toolViewDelegate respondsToSelector:@selector(sendExpressionOrText:messageText:)]){
        [self.toolViewDelegate sendExpressionOrText:emoji messageText:messageText];
    }
    
    [self sendAfter];
}

- (void)sendAfter{
    self.messageTextView.height = 43;
    self.height = functionViewY;
    self.y = Screen_Height - self.keyBoardHeigth - self.height;
    self.functionView.y = 43.0f;
    if ([self.toolViewDelegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:isShowKeyBoard:)]) {
        [self.toolViewDelegate chatToolbarDidChangeFrameToHeight:self.keyBoardHeigth + functionViewY isShowKeyBoard:self.isShowKeyBoard];
    }
}


- (void)showExpression:(UIButton *)typeBtn{
    [self setNormalImage];
    self.isVoiceTalking = NO;//语音输入
    self.isShowExpression = !self.isShowExpression;   //取反
    if (self.isShowExpression) {
        [self resignFirstResponderForView];
        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:self.messageTextView];
        if (!self.messageTextView.isFirstResponder) {
            [self.messageTextView becomeFirstResponder];
        }
        [typeBtn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e664", 30, UIColorFromRGB(0x2ab5f4, 1))] forState:UIControlStateNormal];

    }
    else {
        [self.messageTextView becomeFirstResponder];
        [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    }
}


#pragma mark - toolBar voice
- (void)showVoice:(UIButton *)typeBtn{
    [self setNormalImage];
    self.isShowExpression = NO;
    if(self.isVoiceTalking){ //文字输入
        self.isVoiceTalking = NO;
        //[self.messageTextView becomeFirstResponder];
        [self showTextView];
    }else{  //语音输入
        [typeBtn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e669", 30, UIColorFromRGB(0x2ab5f4, 1))] forState:UIControlStateNormal];
        self.isVoiceTalking = YES;
        self.talkView.hidden = NO;
        self.albumBtn.hidden = YES;
        self.sendImgsBtn.hidden = YES;
        self.chooseImagesView.hidden = YES;
        self.messageTextView.hidden = YES;
        [self resignFirstResponderForView];
        self.lineView.y = 0;
        self.functionView.y = 0.5;
        self.talkView.y = 50;
        self.y = Screen_Height - 50 - 200 - haveNav;
        self.height = functionViewY + 200;
    }
    [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
}

#pragma mark - toolBar show photo libary
- (void)showPhotoLibrary:(UIButton *)typeBtn{
    [self initChooseImages];
    
    self.chooseImagesView.hidden = !self.chooseImagesView.hidden; //显示照片列表
    [self setNormalImage];
    if(self.chooseImagesView.hidden){
        [self showTextView];
    }else{
        [self resignFirstResponderForView];
        [typeBtn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e668", 30, UIColorFromRGB(0x2ab5f4, 1))] forState:UIControlStateNormal];

        [self loadMomentElementsShowIndicatorView:YES];         //加载数据
        self.isShowExpression = NO;                             //表情
        self.isVoiceTalking = NO;                               //语音输入
        self.talkView.hidden = YES;                             //隐藏语音按钮
        self.albumBtn.hidden = NO;                              //进入相册
        self.sendImgsBtn.hidden = NO;                              //进入相册
        self.messageTextView.hidden = NO;                       //显示输入框
        [self bringSubviewToFront:self.albumBtn];               //将view放入最前面
        [self bringSubviewToFront:self.sendImgsBtn];
        [self bringSubviewToFront:self.idView];
        self.lineView.y = 0;
        self.messageTextView.y = 10;
        self.height = self.chooseImagesView.height + functionViewY;
        self.y = Screen_Height - self.height - haveNav;
        self.functionView.y = self.messageTextView.height + 11;
        self.albumBtn.y = CGRectGetMaxY(self.collectionView.frame) + 10 + functionViewY;
        self.sendImgsBtn.y = self.albumBtn.y + 5;
    }
    [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
}

#pragma mark - 相册按钮
- (void)albumBtnClick:(UIButton *)btn{
    UIViewController *vc = [self getCurrentViewController];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    if(self.sendImagesAsset.count > 0)
        imagePickerVc.selectedAssets = self.sendImagesAsset;
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        self.sendImagsBlock ? self.sendImagsBlock(photos) : nil;
    }];
    
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
    NSLog(@"album %s",__FUNCTION__);
}

#pragma mark - 发送图片按钮
- (void)sendImgsBtnClick:(UIButton *)btn{
    if(self.imagesAry){ //如果有选中的图片
        
        __block NSMutableArray *selectImgs = [NSMutableArray array];
        
        for(int i = 0; i < self.sendImagesAsset.count; i++){
            id asset = self.sendImagesAsset[i];
            [[ImageDataAPI sharedInstance] getImageForPhotoObj:asset withSize:CGSizeMake(808, 600) completion:^(BOOL ret, UIImage *image) {
               
                if (image) {
                    [selectImgs addObject:image];
                }
                
                if(i == self.sendImagesAsset.count-1){
                    self.sendImagsBlock ? self.sendImagsBlock(selectImgs) : nil;
                    [self.imagesSelectedIndexAry removeAllObjects];
                    [self.sendImagesAsset removeAllObjects];
                    [self.imagesAry removeAllObjects];
                    self.currentCount = 0;
                    [self.collectionView reloadData];
                }
            }];
        }
        
    }
}

#pragma mark - init tools button
- (void)initSubViewsWithDataDictAry:(NSArray *)dictAry{
    UIView *functionView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, Screen_Width, 55)];
    self.functionView = functionView;
    
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width * 0.2;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.functionView.bounds];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    if(dictAry.count > 0){
        scrollView.contentSize = CGSizeMake(dictAry.count * btnW, 0);
    }
    [self.functionView addSubview:scrollView];
    
    for (int i = 0; i < dictAry.count; i++) {
        ToolBarBtn *toolBtn = [ToolBarBtn buttonWithType:UIButtonTypeCustom];
        CGFloat btnH = 55;
        CGFloat btnX = i * btnW;
        CGFloat btnY = 0;
        toolBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        if ([dictAry[i] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = dictAry[i];
            
            if(dataDict[imageKey])
                [toolBtn setImage:dataDict[imageKey] forState:UIControlStateNormal];
            
            if(dataDict[toolTypeKey])
                toolBtn.typeEnum = [[NSString stringWithFormat:@"%@",dataDict[toolTypeKey]] integerValue];
        }
        toolBtn.tag = i;
        [toolBtn addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:toolBtn];
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
    albumBtn.frame = CGRectMake(15, self.messageTextView.height + 49.6 + 20 + 158, 50, 35);
    albumBtn.hidden = YES;
    albumBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    [albumBtn setTitleColor:UIColorFromRGB(0x0FADFE , 1) forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.albumBtn = albumBtn;
    [self addSubview:albumBtn];
    
    //发送图片按钮
    UIButton *sendImgsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendImgsBtn.frame = CGRectMake(Screen_Width - 65, albumBtn.y + 5, 50, 25);
    sendImgsBtn.hidden = YES;
    sendImgsBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendImgsBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendImgsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendImgsBtn setBackgroundColor:UIColorFromRGB(0x0FADFE, 1)];
    [sendImgsBtn addTarget:self action:@selector(sendImgsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    sendImgsBtn.layer.cornerRadius = 3;
    sendImgsBtn.layer.masksToBounds = YES;
    self.sendImgsBtn = sendImgsBtn;
    [self addSubview:sendImgsBtn];
    
    //说话按钮bg view
    UIView *talkView = [[UIView alloc] initWithFrame:CGRectMake(0, functionViewY, Screen_Width, 200)];    //聊天bg view
    self.talkView = talkView;
    [self addSubview:talkView];
    self.talkView.hidden = YES; //暂时隐藏
    
    //按住说话
    ChatVoiceView *chatVoice = [[ChatVoiceView alloc] initWithFrame:CGRectMake(0, 0, self.width, 200)];
    [talkView addSubview:chatVoice];
    chatVoice.sendMessageWithVoiceBlock = ^(NSString *voicePath, NSString *voiceDuration){
        self.sendMessageWithVoiceBlock != nil ? self.sendMessageWithVoiceBlock(voicePath, voiceDuration) : nil;
    };
    self.voiceView = chatVoice;
    
    
    //输入框
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 0.5)];
    self.lineView = lineView;
    lineView.backgroundColor = UIColorFromRGB(0xd1d1d1, 1);
    [self addSubview:lineView];
    
    MessageTextView *messageTextView = [[MessageTextView alloc] initWithFrame:CGRectMake(10, 10, Screen_Width - 20, 33)];
    messageTextView.delegate = self;
    messageTextView.placeHolder = placeHolderStr;
    messageTextView.placeHolderTextColor = UIColorFromRGB(0xC1BDBB,1);
    messageTextView.returnKeyType = UIReturnKeySend;
    self.messageTextView = messageTextView;
    [self addSubview:messageTextView];
    
    messageTextView.block = ^(CGFloat maxTextHeight, NSString *text, BOOL isChange){
        [self hiddenAllFunction];
        if(maxTextHeight <= 120){
            self.messageTextView.height = maxTextHeight;
            self.messageTextView.y = 10;
            self.lineView.y = 0;
            self.functionView.y = maxTextHeight + 10;
            self.height = 65.5 + maxTextHeight;
        }else{
            self.messageTextView.height = 120;
            self.height = 130 + 55;
            self.functionView.y = 130;
        }
        self.y = Screen_Height - haveNav - self.height - self.keyBoardHeigth;
        if ([self.toolViewDelegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:isShowKeyBoard:)]) {
            [self.toolViewDelegate chatToolbarDidChangeFrameToHeight:Screen_Height - self.y isShowKeyBoard:self.isShowKeyBoard];
        }
    };
    
    UIView *expressionRightView = [[UIView alloc] initWithFrame:CGRectMake(self.width - 1, 0, 1, 1)];
    [self addSubview:expressionRightView];
    
    [[MMEmotionCentre defaultCentre] shouldShowShotcutPopoverAboveView:self withInput:self.messageTextView];
    [MMEmotionCentre defaultCentre].delegate = self;
}

- (BOOL)endEditing:(BOOL)force
{
    if(self.isVoiceTalking && self.voiceView.isRecording)
        return NO;
    
    if(!self.chooseImagesView.hidden || self.isVoiceTalking || self.isShowExpression || force){
        //隐藏所有功能
        [self hiddenAllFunction];
        [self.messageTextView endEditing:YES];
        //隐藏表情键盘
        [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
        [self setNormalImage];
        self.isVoiceTalking = NO;
        self.isShowExpression = NO;
        
        [self returnSelfHeight];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notf{
    self.isShowKeyBoard = YES;
    [self returnSelfHeight];
    [self setNormalImage];
}

- (void)keyboardWillHiden:(NSNotification *)notf{
    self.isShowKeyBoard = NO;
    if(!self.chooseImagesView.hidden) return;
    if(self.isVoiceTalking) return;
    if(self.isShowExpression) return;
    [self returnSelfHeight];
}

#pragma mark - 隐藏所有功能,回到最初状态
- (void)hiddenAllFunction{
    [self hideIndicatorView];
    self.albumBtn.hidden = YES;                     //相册库隐藏
    self.sendImgsBtn.hidden = YES;                  //发送图片隐藏
    self.chooseImagesView.hidden = YES;               //相册隐藏
    self.talkView.hidden = YES;                     //语音按钮隐藏
    self.messageTextView.hidden = NO;               //文字输show
    [self _willShowBottomHeight:0];
}


- (void)dealloc{
    self.sendMessageWithVoiceBlock = nil;
    self.sendExpressionOrTextBlock = nil;
    self.clickTypeBtnBlock = nil;
    self.sendImagsBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end

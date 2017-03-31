//
//  CameraViewController.m
//  test
//
//  Created by 崔浩楠 on 2016/12/23.
//  Copyright © 2016年 chn. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CCCameraManger.h"

@interface CameraViewController ()

- (IBAction)dissmisBtnClick:(UIButton *)sender;

- (IBAction)frontSwitchClick:(UIButton *)sender;
- (IBAction)takePhotoClick:(UIButton *)sender;

@property (nonatomic, strong) CCCameraManger *manger;

@property (assign, nonatomic) ToolsBtnClickType type;
@property (weak, nonatomic) IBOutlet UIImageView *showImgView;

@property (strong, nonatomic) IBOutlet UIView *showImgBgView;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showImgBgView.hidden = YES;
    self.showImgBgView.frame = self.view.bounds;
    [self.view addSubview:self.showImgBgView];
    
    [self.manger startUp];

}

- (CCCameraManger *)manger
{
    if (!_manger) {
        _manger = [[CCCameraManger alloc] initWithParentView:self.view];
        _manger.faceRecognition = YES;
    }
    return _manger;
}

- (void)initAVCaptureSession{
    
}

- (IBAction)dissmisBtnClick:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)frontSwitchClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.manger changeCameraInputDeviceisFront:sender.selected];
}

- (IBAction)takePhotoClick:(UIButton *)sender {
    [self.manger takePhotoWithImageBlock:^(UIImage *originImage, UIImage *scaledImage, UIImage *croppedImage) {
        
        self.showImgView.image = croppedImage;
        [self showImageView];
    }];
}

- (void)showImageView{
    self.showImgBgView.hidden = NO;
}

- (void)hideImageView{
    self.showImgBgView.hidden = YES;
}

- (IBAction)replaceClick:(UIButton *)sender {
    self.type = ToolsBtnClickReplace;
    self.block ? self.block(self.type) : nil;
    [self hideImageView];
}

- (IBAction)cancleClick:(UIButton *)sender {
    self.type = ToolsBtnClickCancle;
    [self dismissViewControllerAnimated:YES completion:nil];
    self.block ? self.block(self.type) : nil;
}

- (IBAction)sendClick:(UIButton *)sender {
    self.type = ToolsBtnClickSend;
    self.block ? self.block(self.type) : nil;
}


- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
@end

//
//  ViewController.m
//  test
//
//  Created by 崔浩楠 on 16/5/5.
//  Copyright © 2016年 chn. All rights reserved.
//

#import "ViewController.h"
#import "ChatToolView.h"
#import "ChatToolMacro.h"
#import "UIView+Extend.h"
#import <objc/runtime.h>
#import "ToolsView.h"

#import <AVFoundation/AVFoundation.h>

#import "SlideView.h"

#import "FeedHeaderView.h"


#define ScreenHigh [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate, UITableViewDataSource>
{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *layer;
}
@property (nonatomic , weak) ChatToolView *chatView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHigh) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    
//    FeedHeaderView *feedView = [[FeedHeaderView alloc] initInstance];
//    feedView.frame = CGRectMake(0, 100, ScreenWidth, 363.5);
//    feedView.dataAry = @[@1,@2,@3,@4,@5];
//    [self.view addSubview:feedView];
    
//    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 80, 80)];
//    redView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:redView];
//    
//    CAKeyframeAnimation *anima1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    NSValue *value0 = [NSValue valueWithCGPoint:CGPointMake(50, 100)];
//    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(150, 50)];
//    anima1.values = [NSArray arrayWithObjects:value0, value1, nil];
//
//    //缩放动画
//    CABasicAnimation *anima2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    anima2.fromValue = [NSNumber numberWithFloat:1.0f];
//    anima2.toValue = [NSNumber numberWithFloat:0.6f];
//    
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    
//    group.animations = [NSArray arrayWithObjects:anima1, anima2, nil];
//    group.duration = 0.5f;
//    group.fillMode = kCAFillModeForwards;
//    group.removedOnCompletion = NO;
//    
//    [redView.layer addAnimation:group forKey:@"groupAnim"];
    
//    UIImage *img = [UIImage imageNamed:@"tupian_icon"];

//    ChatToolView *chatView = [[ChatToolView alloc] initWithImages:@[img,img,img] superView:self.view];
//    chatView.frame = CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, 43 + 49.5f);
//    chatView.y = Screen_Height - chatView.height;
//    self.chatView = chatView;
    
    //return;
    //设备
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    //链接对象
//    session = [[AVCaptureSession alloc] init];
//    
//    NSError *error = nil;
//    //输入流
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//    if (input) {
//        [session addInput:input];
//    }else{
//        NSLog(@"error : %@",[error localizedDescription]);
//    }
//    
//    AVCaptureMetadataOutput *outPut = [[AVCaptureMetadataOutput alloc] init];
//    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    
//    [session setSessionPreset:AVCaptureSessionPresetHigh];
//    [session addOutput:outPut];
//    
//    //支持二维码
//    outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
//    
//    // 1.获取屏幕的frame
//    CGRect viewRect = self.view.frame;
    // 2.获取扫描容器的frame
//    CGRect containerRect = self.customContainerView.frame;
    
//    CGFloat x = containerRect.origin.y / viewRect.size.height;
//    CGFloat y = containerRect.origin.x / viewRect.size.width;
//    CGFloat width = containerRect.size.height / viewRect.size.height;
//    CGFloat height = containerRect.size.width / viewRect.size.width;
    
    // CGRect outRect = CGRectMake(x, y, width, height);
    // [_output rectForMetadataOutputRectOfInterest:outRect];
//    _output.rectOfInterest = CGRectMake(x, y, width, height);

    
//    layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
//    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    
//    layer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [self.view.layer insertSublayer:layer atIndex:0];
//    
//    [session startRunning];
    
//    unsigned int outCount = 0;
//    
//    objc_property_t *properties = class_copyPropertyList([Person class], &outCount);
//    
//    for (int i = 0; i < outCount; i ++) {
//        NSString *name = @(property_getName(properties[i]));
//        NSLog(@"%@", name);
//    }
    
    
//    NSArray *ary = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
//    
//    NSMutableArray *modelAry = [NSMutableArray array];
//    for (int i = 0; i < ary.count; i++) {
//        ToolsModel *model = [[ToolsModel alloc] init];
//        model.title = [NSString stringWithFormat:@"%d",i];
//        model.detail = @"1231312";
//        [modelAry addObject:model];
//    }
//    
//    ToolsView *toolsView = [[ToolsView alloc] initWithModelAry:modelAry];
//    toolsView.frame = CGRectMake(0, 100, Screen_Width, modelAry.count * 80);
//    [self.view addSubview:toolsView];
    
//
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(self.view.center.x, 50, 40, 40);
//    btn.backgroundColor = [UIColor blueColor];
//    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
     
    
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark - tableView delegate
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    NSLog(@"%s",__FUNCTION__);
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s",__FUNCTION__);

    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__FUNCTION__);
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__FUNCTION__);

    static NSString *identifier = @"ide";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *codeStr = nil;
    for (AVMetadataObject *medata in metadataObjects) {
        if ([medata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            NSLog(@"%f ---- %f",medata.bounds.size.width,medata.bounds.size.height);
            codeStr = [(AVMetadataMachineReadableCodeObject *)medata stringValue];
        }
    }
    
//    NSLog(@"codeStr = %@",codeStr);
    
//    [session stopRunning];
}
    
- (void)btnClick:(UIButton *)btn{
    
    for (UIImage *image in self.chatView.imagesAry) {
        NSLog(@"%@",image);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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

@interface ViewController ()

@property (nonatomic , weak) ChatToolView *chatView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"tupian_icon"];
    
    ChatToolView *chatView = [[ChatToolView alloc] initWithImages:@[img,img,img] superView:self.view];
    chatView.frame = CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, 43 + 49.5f);
    chatView.y = Screen_Height - chatView.height;
    self.chatView = chatView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.center.x, 50, 40, 40);
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
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

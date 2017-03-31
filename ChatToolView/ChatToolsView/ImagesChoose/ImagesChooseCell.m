//
//  ImagesChooseCell.m
//  test
//
//  Created by 崔浩楠 on 2016/12/22.
//  Copyright © 2016年 chn. All rights reserved.
//

#define UIColorFromRGB(rgbValue, alph) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(alph)]

#import "ImagesChooseCell.h"

@interface ImagesChooseCell()

@property (weak, nonatomic) IBOutlet UIButton *indexBtn;

- (IBAction)indexBtnClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIView *statusView;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation ImagesChooseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.statusView.layer.cornerRadius = 10.0f;
    self.statusView.layer.masksToBounds = YES;
    self.statusView.layer.borderWidth = 1;
    self.statusView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)configureForImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)setSelectedWithAry:(NSArray *)selectedAry{
    for (int i = 0; i < selectedAry.count; i++) {
        NSDictionary *dict = selectedAry[i];
        NSInteger dictTag = [[[dict allKeys] firstObject] integerValue];
        if (self.tag == dictTag) {
            [self changeColor:YES];
            self.numberLabel.text = [NSString stringWithFormat:@"%ld",[dict[[NSString stringWithFormat:@"%ld",self.tag]] integerValue]];
//            [self.indexBtn setTitle: forState:UIControlStateNormal];
            break;
        }else{
            self.numberLabel.text = @"";
//            [self.indexBtn setTitle:@"" forState:UIControlStateNormal];
            [self changeColor:NO];
        }
    }
    if([selectedAry count] == 0){
        self.numberLabel.text = @"";
//        [self.indexBtn setTitle:@"" forState:UIControlStateNormal];
        [self changeColor:NO];
    }
}

- (IBAction)indexBtnClick:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        
        [self changeColor:NO];
    }else{
        sender.selected = YES;
        
        [self changeColor:YES];
    }
    self.block(self,@(self.tag),sender.selected);
}

- (void)changeColor:(BOOL)status{
    self.indexBtn.selected = status;
    if (status) {
        self.shadowView.hidden = NO;
        self.statusView.backgroundColor = UIColorFromRGB(0xFFD100,1);
        self.statusView.layer.borderColor = [UIColor clearColor].CGColor;
    }else{
        self.shadowView.hidden = YES;
        self.statusView.backgroundColor = UIColorFromRGB(0x000000,0.3);
        self.statusView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

@end

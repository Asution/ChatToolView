//
//  ImagesChooseCell.m
//  test
//
//  Created by 崔浩楠 on 2016/12/22.
//  Copyright © 2016年 chn. All rights reserved.
//

#define UIColorFromRGB(rgbValue, alph) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(alph)]

#import "ImagesChooseCell.h"
#import "UIImageView+Extend.h"

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
    
    self.imageView.clipsToBounds = YES;
    self.numberLabel.textColor = [UIColor whiteColor];
    self.statusView.layer.cornerRadius = 10.0f;
    self.statusView.layer.masksToBounds = YES;
    self.statusView.layer.borderWidth = 1;
    self.statusView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)configureForImage:(UIImage *)image
{
//    UIImage *compressImg = [self.imageView imageCompressForSize:image maxSize:self.imageView.frame.size.height];
    self.imageView.image = image;
}

- (void)setSelectedWithAry:(NSArray *)selectedAry{

    for (int i = 0; i < selectedAry.count; i++) {
        NSDictionary *dict = selectedAry[i];
        NSInteger dictTag = [[[dict allKeys] firstObject] integerValue];
        if (self.tag == dictTag) {
            [self changeColor:YES];
            self.numberLabel.text = [NSString stringWithFormat:@"%@",dict[[NSString stringWithFormat:@"%ld",self.tag]]];
            break;
        }else{
            self.numberLabel.text = @"";
            [self changeColor:NO];
        }
    }
    if([selectedAry count] == 0){
        self.numberLabel.text = @"";
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
    self.imageClickBlock ? self.imageClickBlock(self,@(self.tag),sender.selected,self.indexPath, self.asset) : nil;
}

- (void)changeColor:(BOOL)status{
    self.indexBtn.selected = status;
    if (status) {
//        self.shadowView.hidden = NO;
        self.statusView.backgroundColor = UIColorFromRGB(0x0FADFE,1);
        self.statusView.layer.borderColor = [UIColor clearColor].CGColor;
    }else{
//        self.shadowView.hidden = YES;
        self.statusView.backgroundColor = UIColorFromRGB(0x000000,0.3);
        self.statusView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

@end

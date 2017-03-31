//
//  HeaderCollectionViewCell.m
//  test
//
//  Created by 崔浩楠 on 2017/3/22.
//  Copyright © 2017年 chn. All rights reserved.
//

#import "HeaderCollectionViewCell.h"

@interface HeaderCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *activityImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLanel;

@end

@implementation HeaderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end

//
//  ImagesChooseCell.h
//  test
//
//  Created by 崔浩楠 on 2016/12/22.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageClickBlock)(id cell, NSNumber *tag, BOOL  selected);

@interface ImagesChooseCell : UICollectionViewCell

@property (nonatomic , copy) ImageClickBlock block;

- (void)configureForImage:(UIImage *)image;

- (void)setSelectedWithAry:(NSArray *)selectedAry;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

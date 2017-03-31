//
//  ImagesChooseCell.h
//  test
//
//  Created by 崔浩楠 on 2016/12/22.
//  Copyright © 2016年 chn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageClickBlock)(id cell, NSNumber *tag, BOOL  selected, NSIndexPath *indexPath, id asset);

@interface ImagesChooseCell : UICollectionViewCell

@property (nonatomic, strong) id asset;

@property (nonatomic , copy) ImageClickBlock imageClickBlock;

@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)configureForImage:(UIImage *)image;

@property (nonatomic, strong) UIImage *normalImage;

- (void)setSelectedWithAry:(NSArray *)selectedAry;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

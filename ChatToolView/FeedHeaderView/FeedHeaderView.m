//
//  FeedHeaderView.m
//  test
//
//  Created by 崔浩楠 on 2017/3/22.
//  Copyright © 2017年 chn. All rights reserved.
//

#import "FeedHeaderView.h"
#import "ChatToolMacro.h"
#import "HeaderCollectionViewCell.h"

static NSString *const kIdentifier = @"headerCollectionViewCell";

@interface FeedHeaderView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *moreLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)moreBtnClick:(id)sender;
@end

@implementation FeedHeaderView

- (instancetype)initInstance{
    __block FeedHeaderView *feedView = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        feedView = [[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0];
        [feedView.collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kIdentifier];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(165, 202 + 96.5);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        feedView.collectionView.collectionViewLayout = layout;

    });
    return feedView;
}

- (void)setDataAry:(NSArray *)dataAry{
    _dataAry = dataAry;
    if(!self.collectionView.delegate || !self.collectionView.dataSource){
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }
    
    [self.collectionView reloadData];
}

- (void)moreBtnClick:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataAry count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",@(indexPath.row).description);
}

@end

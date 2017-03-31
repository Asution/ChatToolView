//
//  MomentDataSource.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "MomentDataSource.h"
#import "MomentCollection.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#define PSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation MomentDataSource

- (id)initWithCellIdentifier:(NSString *)cellID
            headerIdentifier:(NSString *)headerID
          configureCellBlock:(CellConfigureBlock)block
{
    self.headerIdentifier = headerID;
    
    return [self initWithCellIdentifier:cellID configureCellBlock:block];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.items count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MomentCollection *group = [self.items objectAtIndex:section];
    
    return [group.assetObjs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                           forIndexPath:indexPath];
    
    MomentCollection *group = [self.items objectAtIndex:indexPath.section];
    
    // set tag for reuse determination
    cell.tag = indexPath.section * 100 + indexPath.row;
    
    id item = group.assetObjs[indexPath.row];
    self.block(cell, item, indexPath);

    return cell;
}

#pragma mark - 删除数组中的选择并更新选择个数
- (NSMutableArray *)setSelectedAryAndUpdateCount:(NSArray *)ary tag:(NSNumber *)tag{
    NSMutableArray *mutAry = [ary mutableCopy];     //循环数组
    NSInteger removeIndex = 0;
    if (mutAry.count > 0) {
        for (int i = 0; i < ary.count; i++) {
            NSMutableDictionary *dict = [ary[i] mutableCopy];
            NSInteger dictTag = [[[dict allKeys] firstObject] integerValue];
            if ([tag integerValue] == dictTag) {
                removeIndex = [[[dict allValues] firstObject] integerValue];
                [mutAry removeObject:dict];
            }
        }
        // value > remove index , value = - 1
        for (int j = 0; j < mutAry.count; j++) {
            NSMutableDictionary *dict = [mutAry[j] mutableCopy];
            NSString *dictTag = [[dict allKeys] firstObject];
            NSString *dictValue = [NSString stringWithFormat:@"%ld",[[[dict allValues] firstObject] integerValue]] ;
            if([dictValue integerValue] > removeIndex)
                dictValue = [NSString stringWithFormat:@"%ld",[dictValue integerValue] - 1];
            
            [dict setValue:dictValue forKey:dictTag];
            mutAry[j] = dict;
        }
    }else{
        [mutAry removeAllObjects];
    }
    return mutAry;
}

#pragma mark - 查看是否存在于数组
- (BOOL)checkHaveTagWithAry:(NSArray *)ary tag:(NSNumber *)tag{
    BOOL have = NO;
    for (int i = 0; i < ary.count; i++) {
        NSDictionary *dict = ary[i];
        NSInteger dictTag = [[[dict allKeys] firstObject] integerValue];
        if ([tag integerValue] == dictTag) {
            have = YES;
            break;
        }
    }
    return have;
}

/*
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.headerIdentifier forIndexPath:indexPath];
        
        while ([headerView.subviews lastObject] != nil)
        {
            [(UIView*)[headerView.subviews lastObject] removeFromSuperview];
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PSCREEN_WIDTH, 48)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, PSCREEN_WIDTH-8, 48)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        
        MomentCollection *group = (MomentCollection *)[self.items objectAtIndex:indexPath.section];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%lu-%lu-%lu",
                                                      (unsigned long)group.year,
                                                      (unsigned long)group.month,
                                                      (unsigned long)group.day]];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit   |
                                                                                NSMonthCalendarUnit |
                                                                                NSYearCalendarUnit
                                                                       fromDate:[NSDate date]];
        NSUInteger month = [components month];
        NSUInteger year  = [components year];
        NSUInteger day   = [components day];
        
        NSString *localization = [NSBundle mainBundle].preferredLocalizations.firstObject;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
        
        dateFormatter.locale    = locale;
        dateFormatter.dateStyle = kCFDateFormatterLongStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        
        if (year == group.year)
        {
            NSString *longFormatWithoutYear = [NSDateFormatter dateFormatFromTemplate:@"MMMM d"
                                                                              options:0
                                                                               locale:locale];
            [dateFormatter setDateFormat:longFormatWithoutYear];
        }
        
        NSString *resultString = [dateFormatter stringFromDate:date];
        
        if (year == group.year && month == group.month)
        {
            if (day == group.day)
            {
                resultString = NSLocalizedString(@"Today", nil);
            }
            else if (day - 1 == group.day)
            {
                resultString = NSLocalizedString(@"Yesterday", nil);
            }
        }
        
        [label setText:resultString]; [view addSubview:label];
        [headerView addSubview:view]; reusableview = headerView;
    }
    
    return reusableview;
}
*/
@end

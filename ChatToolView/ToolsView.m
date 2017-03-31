//
//  ToolsView.m
//  youplus
//
//  Created by 崔浩楠 on 2017/1/3.
//  Copyright © 2017年 guangzhou youplus. All rights reserved.
//

//颜色
#define UIColorFromRGB(rgbValue, alph) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(alph)]

// Size
#define Screen_Width  [[UIScreen mainScreen] bounds].size.width
#define Screen_Height [[UIScreen mainScreen] bounds].size.height

#import "ToolsView.h"
#import "UIView+Extend.h"

@implementation ToolsModel
@end

@interface GroupView : UIView

@property (nonatomic, strong) UIImage *typeImg;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *detail;

@property (nonatomic , weak) UILabel *detailLabel;
@property (nonatomic , weak) UILabel *titleLabel;
@property (nonatomic , weak) UIView  *redView;
@property (nonatomic , weak) UIView *bottomLineView;

@property (assign, nonatomic) BOOL hidenBottomLine;
@end


@implementation GroupView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //subviews
        [self insertSubviews];
    }
    return self;
}

#pragma mar - 创建子控件
- (void)insertSubviews{
    //type images
    UIImageView *typeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18.5, 22.5, 17, 17)];
    [typeImgView setImage:self.typeImg];
    [self addSubview:typeImgView];
    
    //title lable
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeImgView.frame) + 12.5, 0, 0, 18)];
    self.titleLabel = titleLabel;
    titleLabel.centerY = typeImgView.centerY;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = UIColorFromRGB(0x44403c,1);
    [self addSubview:titleLabel];
    
    //detial label
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame) + 4.5, 0, 18)];
    self.detailLabel = detailLabel;
    detailLabel.font = [UIFont systemFontOfSize:12];
    detailLabel.text = _detail;
    detailLabel.textColor = UIColorFromRGB(0xb0aba9,1);
    [self addSubview:detailLabel];
    /**
    //red view
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 8, 0, 8, 8)];
    redView.backgroundColor = UIColorFromRGB(0xff3100, 1);
    self.redView = redView;
    redView.centerY = titleLabel.centerY;
    redView.layer.cornerRadius = 4.0f;
    redView.layer.masksToBounds = YES;
    [self addSubview:redView];
     */
    
    //line view - right
    UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, 0.5, self.frame.size.height)];
    rightLineView.backgroundColor = UIColorFromRGB(0xf1f1f1, 1);
    [self addSubview:rightLineView];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width * 0.5, 0.5)];
    topLineView.backgroundColor = UIColorFromRGB(0xf1f1f1, 1);
    [self addSubview:topLineView];
    
    //line view - bottom
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.5)];
    bottomLineView.backgroundColor = UIColorFromRGB(0xf1f1f1, 1);
    self.bottomLineView = bottomLineView;
    [self addSubview:bottomLineView];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    CGSize titleSize = [self computeSizeWithFont:15 str:title];
    self.titleLabel.width = titleSize.width;
    self.titleLabel.text = title;
    self.redView.x = CGRectGetMaxX(self.titleLabel.frame) + 8;
}

- (void)setDetail:(NSString *)detail{
    _detail = detail;
    CGSize detailSize = [self computeSizeWithFont:15 str:_detail];
    self.detailLabel.width = detailSize.width;
    self.detailLabel.text = detail;
}

- (void)setHidenBottomLine:(BOOL)hidenBottomLine{
    _hidenBottomLine = hidenBottomLine;
    if (hidenBottomLine) {
        self.bottomLineView.hidden = YES;
    }
}

- (CGSize)computeSizeWithFont:(CGFloat)fonts str:(NSString *)str{
    UIFont *font = [UIFont systemFontOfSize:fonts];
    NSDictionary *attrs=@{NSFontAttributeName:font};
    CGSize s = [str boundingRectWithSize:CGSizeMake(self.bounds.size.width, 18) options:NSStringDrawingTruncatesLastVisibleLine |
              NSStringDrawingUsesLineFragmentOrigin |
              NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    return s;
}

@end

@implementation ToolsView

- (instancetype)initWithModelAry:(NSArray *)modelAry{
    self = [super init];
    
    if (self) {
        
        for (int i = 0; i < modelAry.count; i++) {
            ToolsModel *model = modelAry[i];
            CGFloat x = i % 2 == 0 ? 0 : Screen_Width * 0.5;
            NSInteger y = i / 2 * 80;
            CGFloat width = Screen_Width * 0.5;
            CGFloat height = 80;
            GroupView *groupView = [[GroupView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
            if(modelAry.count % 2 == 0){ //底部有两个view
                if(i % 2 == 0 && i == modelAry.count - 2){
                    groupView.hidenBottomLine = YES;
                }
                
                if(i % 2 == 1 && i == modelAry.count - 1){
                    groupView.hidenBottomLine = YES;
                }
            }else{
                if(i % 2 == 0 && i == modelAry.count - 1){
                    groupView.hidenBottomLine = YES;
                }
            }
            
            groupView.title = model.title;
            groupView.detail = model.detail;
            
            [self addSubview:groupView];
        }
        
    }
    return self;
}

//- (UIImage *)typeImageWithStr:(NSString )

@end

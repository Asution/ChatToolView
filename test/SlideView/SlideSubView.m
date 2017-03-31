//
//  SlideSubView.m
//  test
//
//  Created by 崔浩楠 on 2017/3/14.
//  Copyright © 2017年 chn. All rights reserved.
//

#import "SlideSubView.h"
#import "SlideCALayer.h"

@interface SlideSubView()
@property (nonatomic,strong)SlideCALayer *curveLayer;
@end

@implementation SlideSubView

+ (Class)layerClass{
    return [SlideCALayer class];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}


-(void)setProgress:(CGFloat)progress{
    self.curveLayer.progress = progress;
    [self.curveLayer setNeedsDisplay];
    
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    self.curveLayer = [SlideCALayer layer];
    self.curveLayer.frame = self.bounds;
    self.curveLayer.contentsScale = [UIScreen mainScreen].scale;
    self.curveLayer.progress = 0.0f;
    [self.curveLayer setNeedsDisplay];
    [self.layer addSublayer:self.curveLayer];
    
}


@end

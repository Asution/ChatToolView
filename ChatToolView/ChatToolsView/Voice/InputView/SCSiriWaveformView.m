//
//  SCSiriWaveformView.m
//  SCSiriWaveformView
//
//  Created by Stefan Ceriu on 12/04/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "SCSiriWaveformView.h"
#import "ChatToolMacro.h"

@interface SCSiriWaveformView ()

@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, assign) CGFloat amplitude;

@property (assign, nonatomic) BOOL isDelete;

@end

@implementation SCSiriWaveformView

- (id)init
{
    if(self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.frequency = 1.5f;          // 频率
    
    self.amplitude = 6.0f;          // 振幅
    self.idleAmplitude = 0.01f;     // 空载振幅
    
    self.numberOfWaves = 2;         // 波浪的数量
    self.phaseShift = -0.07f;       // 周相移动
    self.density = 5.0f;            // 密度
    
    self.waveColor = [UIColor whiteColor];
    self.primaryWaveLineWidth = 2.0f;
    self.secondaryWaveLineWidth = 2.0f;
    self.frame = self.superViewFrame;
}

-(void)updateWithLevel:(CGFloat)level
{
    self.phase += self.phaseShift;
    self.amplitude = fmax( level, self.idleAmplitude);
    
    [self setNeedsDisplay];
}

- (void)changeColorIsDelete:(BOOL)isDelete{
    self.isDelete = isDelete;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextClearRect(context, self.bounds);
    
    //    [self.backgroundColor set];
    //    CGContextFillRect(context, self.superViewFrame);
    
    // We draw multiple sinus waves, with equal phases but altered amplitudes, multiplied by a parable function.
    for(int i=0; i < self.numberOfWaves; i++) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, (i==0 ? self.primaryWaveLineWidth : self.secondaryWaveLineWidth));
        
        CGFloat halfHeight = CGRectGetHeight(self.superViewFrame) / 2.0f;
        CGFloat width = CGRectGetWidth(self.superViewFrame);
        CGFloat mid = width / 2.0f;
        
        const CGFloat maxAmplitude = halfHeight - 4.0f; // 4 corresponds to twice the stroke width
        
        // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
        CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWaves;
        CGFloat normedAmplitude = (1.5f * progress - 0.5f) * self.amplitude;
        
//        CGFloat multiplier = MIN(1.0, (progress / 3.0f * 2.0f) + (1.0f / 3.0f));
//        [[self.waveColor colorWithAlphaComponent:multiplier * CGColorGetAlpha(self.waveColor.CGColor)] set];
        
        if(_isDelete){
            if (i % 2 == 1) {
                self.waveColor = UIColorFromRGB(0xFC4E5D, 1);
            } else {
                self.waveColor = UIColorFromRGB(0xFCB8BC, 1);
            }
        }else{
            if (i % 2 == 1) {
                self.waveColor = UIColorFromRGB(0x23A1FE, 1);
            } else {
                self.waveColor = UIColorFromRGB(0xB8E5FF, 1);
            }
        }
        
        [[self.waveColor colorWithAlphaComponent:0.5] set];
        
        for(CGFloat x = 0; x<width + self.density; x += self.density) {
            
            // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
            CGFloat scaling = -pow(1 / mid * (x - mid), 2) + 1;
            
            CGFloat y = scaling * maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / width) * self.frequency + self.phase) + halfHeight + 20;
            
            if (x==0) {
                CGContextMoveToPoint(context, x, y);
            }
            else {
                CGContextAddLineToPoint(context, x, y);
            }
        }
        
        CGContextStrokePath(context);
    }
    self.backgroundColor = [UIColor whiteColor];
}

@end

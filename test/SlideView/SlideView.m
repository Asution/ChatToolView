//
//  SlideView.m
//  test
//
//  Created by 崔浩楠 on 2017/3/14.
//  Copyright © 2017年 chn. All rights reserved.
//

#import "SlideView.h"
#import "SlideSubView.h"
#import "SlideCALayer.h"

// Size
#define Screen_Width  [[UIScreen mainScreen] bounds].size.width
#define Screen_Height [[UIScreen mainScreen] bounds].size.height


@interface SlideView()<UIScrollViewDelegate>

@property (nonatomic, assign)CGFloat progress;
@property (nonatomic, weak)UIScrollView *associatedScrollView;
@property (nonatomic, strong) SlideSubView *slideSubView;
@property (assign, nonatomic) CGFloat currentOffSet;
@end

@implementation SlideView

- (id)initWithSlideScrollView:(UIScrollView *)scrollView titleAry:(NSArray *)titleAry{
    self = [super initWithFrame:CGRectMake(scrollView.width/2-200/2, -100, 200, 100)];
    if (self) {
        
        self.associatedScrollView = scrollView;
        self.associatedScrollView.delegate = self;
        [self setUpView];
        [self.associatedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.associatedScrollView insertSubview:self atIndex:0];
        
    }
    return self;
}

-(void)setProgress:(CGFloat)progress{
    
//    NSLog(@"%f",progress);
    self.slideSubView.progress = progress;
}

- (void)setUpView{
    
}


#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        CGFloat scWidth = self.associatedScrollView.frame.size.width;
        if (contentOffset.x) {
            self.progress = MAX(0.0, MIN(fabs(contentOffset.x) / scWidth, 1.0));
        }else if (1){
            self.progress = 0;
        }
        
//        NSLog(@"%f",scWidth / contentOffset.x);
    }
}


#pragma dealloc

-(void)dealloc{
    [self.associatedScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end

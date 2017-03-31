# ChatToolView

这是一个基于环信（如果你也基于环信，那么修改的地方将会很少） 的IM Chat Tools Bar View

##这是最简单的初始化
``` 
    CGFloat toolBarHeight = 43 + 55;
    // select status UIColorFromRGB(0x2ab5f4, 1)
    UIImage *voiceImg = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66e", 30, UIColorFromRGB(0xd8d8d8, 1))];
    UIImage *photoImg = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66d", 30, UIColorFromRGB(0xd8d8d8, 1))];
    UIImage *cameraImg = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66c", 30, UIColorFromRGB(0xd8d8d8, 1))];
    UIImage *emojiImg = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66a", 30, UIColorFromRGB(0xd8d8d8, 1))];
    UIImage *redImg = [UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e66b", 30, UIColorFromRGB(0xd8d8d8, 1))];
    
    CGRect toolBarFrame = CGRectMake(0,
                                     HCDH - toolBarHeight,
                                     CGRectGetWidth([UIScreen mainScreen].bounds),
                                     toolBarHeight);
    
    NSMutableArray *mutAry = [[NSMutableArray alloc] init];
    [mutAry addObject:@{imageKey:voiceImg,toolTypeKey:@(ChatToolViewTypeEnumVoice)}];
    [mutAry addObject:@{imageKey:photoImg,toolTypeKey:@(ChatToolViewTypeEnumPhoto)}];
    [mutAry addObject:@{imageKey:cameraImg,toolTypeKey:@(ChatToolViewTypeEnumCamera)}];
    [mutAry addObject:@{imageKey:emojiImg,toolTypeKey:@(ChatToolViewTypeEnumEmoji)}];
    [mutAry addObject:@{imageKey:redImg,toolTypeKey:@(ChatToolViewTypeEnumRed)}];
    
    ChatToolView *tooBar = [[ChatToolView alloc] initWithDataDictAry:mutAry
                                                           superView:nil
                                                               frame:toolBarFrame];
    _easeMessageViewController.chatToolbar = tooBar;
    tooBar.toolViewDelegate = self;
 ```
##其他功能可以深入探索，写的也相对简单
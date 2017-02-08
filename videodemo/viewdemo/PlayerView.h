//
//  PlayerView.h
//  videodemo
//
//  Created by meipaipai on 17/2/3.
//  Copyright © 2017年 meipaipai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView

//全屏
@property (nonatomic, copy) void (^pushBlockWithView)();
@property (nonatomic, copy) void (^popBlockWithView)();


-(void)changeFrame:(CGRect)frame;

@end

//
//  AppDelegate.h
//  videodemo
//
//  Created by meipaipai on 17/2/3.
//  Copyright © 2017年 meipaipai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/**
 *  是否强制横屏
 */
@property  BOOL isForceLandscape;
/**
 *  是否强制竖屏
 */
@property  BOOL isForcePortrait;


@end


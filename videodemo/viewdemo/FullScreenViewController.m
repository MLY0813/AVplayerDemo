//
//  FullScreenViewController.m
//  videodemo
//
//  Created by meipaipai on 17/2/4.
//  Copyright © 2017年 meipaipai. All rights reserved.
//

#import "FullScreenViewController.h"
#import "AppDelegate.h"

@interface FullScreenViewController ()

@end

@implementation FullScreenViewController

-(void)viewWillAppear:(BOOL)animated{
    [self forceOrientationLandscape];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = YES;
    [(PlayerView *)self.screenView changeFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    [self.view addSubview:self.screenView];
}

/**
 *  强制横屏
 */
-(void)forceOrientationLandscape{
    //这段代码，只能旋转屏幕不能达到强制横屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    //加上代理类里的方法，旋转屏幕可以达到强制横屏的效果
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

-(void)viewWillDisappear:(BOOL)animated{
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  HomeViewController.m
//  videodemo
//
//  Created by meipaipai on 17/2/4.
//  Copyright © 2017年 meipaipai. All rights reserved.
//

#import "HomeViewController.h"
#import "PlayerView.h"
#import "FullScreenViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()
@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) FullScreenViewController *fullScreenViewController;
@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self forceOrientationPortrait]; //强制竖屏
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9)];
    [self.view addSubview:self.playerView];
    
    __weak typeof(self) weekself = self;
    //全屏
    self.playerView.pushBlockWithView = ^(){
        weekself.fullScreenViewController = [[FullScreenViewController alloc] init];
        [weekself.playerView removeFromSuperview];
        weekself.fullScreenViewController.screenView = weekself.playerView;
        [weekself.navigationController presentViewController:weekself.fullScreenViewController animated:YES completion:^{
            
        }];
    };
    //小屏
    self.playerView.popBlockWithView = ^(){
        [weekself.fullScreenViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
        [weekself.view addSubview:weekself.playerView];
        [weekself.playerView changeFrame:CGRectMake(0, 0, weekself.view.bounds.size.width, weekself.view.bounds.size.width / 16 * 9)];
    };
}

/**
 *  强制竖屏
 */
-(void)forceOrientationPortrait{
    //这段代码，只能旋转屏幕不能达到强制竖屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationMaskPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

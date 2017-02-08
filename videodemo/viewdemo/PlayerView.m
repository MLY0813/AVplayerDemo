//
//  PlayerView.m
//  videodemo
//
//  Created by meipaipai on 17/2/3.
//  Copyright © 2017年 meipaipai. All rights reserved.
//

#import "PlayerView.h"
#import "LykSlider.h"

@interface PlayerView ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic, strong) NSString *totalTime;//视频总时间
@property (nonatomic, strong) NSDateFormatter *dateFormatter;//时间格式
//控制台
@property (nonatomic, strong) UIView *controlView;//控制台视图
@property (nonatomic, strong) UIButton *playButton;//播放按钮
@property (nonatomic, strong) LykSlider *playSlider;//进度条
@property (nonatomic, strong) UILabel *playTime;//播放时间
@property (nonatomic, strong) UIButton *fullScreen;//全屏
@end

static UIImage *thumbImage;

@implementation PlayerView

-(void)dealloc{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeTimeObserver:self.playbackTimeObserver];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSURL *videoUrl = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
        self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        //解决iOS 10偶尔播放不了的问题
        if([[UIDevice currentDevice] systemVersion].intValue>=10){
            //      增加下面这行可以解决ios10兼容性问题了
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
        
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        //  监听status属性
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //  监听loadedTimeRanges属性
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.player play];
    }
    return self;
}
//重写layer方法
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
//重写get方法
- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}
//重写set方法
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

//KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        //准备播放
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            // 转换成秒
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
            // 转换成播放时间
            self.totalTime = [self convertTime:totalSecond];
            // 监听播放状态
            [self monitoringPlayback:self.playerItem];
            //控制台UI
            [self customVideoSlider:totalSecond];
            
        } else if (playerItem.status == AVPlayerStatusFailed) {
            NSLog(@"播放失败");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CGFloat currentSecond = playerItem.currentTime.value / playerItem.currentTime.timescale;
        //缓冲好后自动播放
        if (timeInterval > currentSecond && self.playButton.selected == NO) {
            [self.player play];
        }
    }
}

//缓冲
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
//视频总时间转换
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}
//dateFormatter懒加载
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

//监听播放状态
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        // 计算当前在第几秒
        CGFloat currentSecond = playerItem.currentTime.value / playerItem.currentTime.timescale;
        NSString *timeString = [weakSelf convertTime:currentSecond];
        NSLog(@"%@", timeString);
        weakSelf.playSlider.value = currentSecond;
        weakSelf.playTime.text = [NSString stringWithFormat:@"%@/%@", timeString, weakSelf.totalTime];
    }];
}

//自定义控制台
- (void)customVideoSlider:(CGFloat)second {
    //控制台视图
    self.controlView = [[UIView alloc] init];
    self.controlView.alpha = 0.8;
    self.controlView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.controlView];
    //播放按钮
    float itemY = self.controlView.bounds.size.height / 6;
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.playButton.selected) {
        [self.playButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"videoStop"] forState:UIControlStateNormal];
    }
    [self.playButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.controlView addSubview:self.playButton];
    //视频时间
    self.playTime = [[UILabel alloc] init];
    self.playTime.textColor = [UIColor whiteColor];
    self.playTime.font = [UIFont systemFontOfSize:itemY * 2];
    self.playTime.text = [NSString stringWithFormat:@"00:00/%@", self.totalTime];
    [self.controlView addSubview:self.playTime];
    //全屏
    self.fullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreen setImage:[UIImage imageNamed:@"videoBig"] forState:UIControlStateNormal];
    [self.fullScreen addTarget:self action:@selector(clickFullButton:) forControlEvents:UIControlEventTouchDown];
    [self.controlView addSubview:self.fullScreen];
    //进度条
    self.playSlider = [[LykSlider alloc] init];
    self.playSlider.minimumValue = 0;// 设置最小值
    self.playSlider.maximumValue = second;// 设置最大值
    self.playSlider.value = 0;// 设置初始值
    self.playSlider.continuous = NO;// 设置可连续变化,yes连续变化会触发方法，no当滑块拖动停止会触发方法
    [self.playSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlView addSubview:self.playSlider];
    
    [self changeFrame:self.frame];
}

//控制台按钮点击事件
-(void)clickButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.playButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
        [self.player pause];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"videoStop"] forState:UIControlStateNormal];
        [self.player play];
    }
}

//全屏按钮点击事件
-(void)clickFullButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.fullScreen setImage:[UIImage imageNamed:@"videoSmall"] forState:UIControlStateNormal];
        self.pushBlockWithView();
    } else {
        [self.fullScreen setImage:[UIImage imageNamed:@"videoBig"] forState:UIControlStateNormal];
        self.popBlockWithView();
    }
}

//改变frame
-(void)changeFrame:(CGRect)frame{
    self.frame = frame;
    self.controlView.frame = CGRectMake(0, self.bounds.size.height / 7 * 6, self.bounds.size.width, self.bounds.size.height / 7);
    float itemY = self.controlView.bounds.size.height / 6;
    self.playButton.frame = CGRectMake(itemY, itemY, self.controlView.bounds.size.height - itemY * 2, self.controlView.bounds.size.height - itemY * 2);
    self.playTime.frame = CGRectMake(self.playButton.frame.size.width + itemY * 6, itemY * 2, 200, itemY * 2);
    self.playTime.font = [UIFont systemFontOfSize:itemY * 2];
    self.fullScreen.frame = CGRectMake(self.bounds.size.width - self.controlView.bounds.size.height, itemY, self.controlView.bounds.size.height - itemY * 2, self.controlView.bounds.size.height - itemY * 2);
    self.playSlider.frame = CGRectMake(0, -itemY, self.controlView.bounds.size.width, itemY * 2);
    thumbImage = [self OriginImage:[UIImage imageNamed:@"videoThum"] scaleToSize:CGSizeMake(itemY * 2, itemY * 2)];
    [self.playSlider setThumbImage:thumbImage forState:UIControlStateNormal];
}

//裁剪图片大小
-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

-(void)sliderValueChanged:(UISlider *)sender{
    [self.player seekToTime:CMTimeMake(sender.value,1)];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {

    }];
}

@end

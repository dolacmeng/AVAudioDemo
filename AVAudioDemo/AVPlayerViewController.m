//
//  AVPlayerViewController.m
//  AVAudioDemo
//
//  Created by pconline on 2017/8/23.
//  Copyright © 2017年 pconline. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerViewController ()

@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,assign) BOOL isPlaying;
@property(nonatomic,weak) UILabel *stateLabel;
@property(nonatomic,weak) UIProgressView *loadingProgressView;
@property(nonatomic,weak) UIProgressView *playingProgressView;
@property(nonatomic,strong) id timeObserver;

@end

@implementation AVPlayerViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setUpView];
    [self prepareToPlay];

}

-(void)setUpView{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //播放暂停按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    button.center = self.view.center;
    [button setTitle:@"播放网络音乐" forState:UIControlStateNormal];
    [button setTitle:@"暂停" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:0];
    [button addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //播放状态
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame)+10, self.view.bounds.size.width, 30)];
    stateLabel.textColor = [UIColor grayColor];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel = stateLabel;
    [self.view addSubview:stateLabel];
    
    //缓冲进度条
    UIProgressView *loadingProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20,CGRectGetMaxY(stateLabel.frame)+10,self.view.bounds.size.width-40,10.0)];
    loadingProgressView.progress = 0.0;
    loadingProgressView.trackTintColor = [UIColor greenColor];
    loadingProgressView.progressTintColor= [UIColor darkGrayColor];
    self.loadingProgressView = loadingProgressView;
    [self.view addSubview:loadingProgressView];
    
    //播放进度条
    UIProgressView *playingProgressView = [[UIProgressView alloc] initWithFrame:loadingProgressView.frame];
    playingProgressView.progress = 0.0;
    playingProgressView.trackTintColor = [UIColor clearColor];
    playingProgressView.progressTintColor= [UIColor redColor];
    self.playingProgressView = playingProgressView;
    [self.view addSubview:playingProgressView];
    
}

- (void)clickPlay:(UIButton*)button{
    
    if(!self.isPlaying){
        [self.player play];
        button.selected = YES;
        self.isPlaying = YES;
    }else{
        [self.player pause];
        button.selected = NO;
        self.isPlaying = NO;
    }
    
}

- (void)prepareToPlay{
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://mp3.haoduoge.com/s/2017-08-22/1503362742.mp3"]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"loadedTimeRanges"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    __weak typeof(self) weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time);
        //总时间
        float total = CMTimeGetSeconds(item.duration);
        if (current) {
            float progress = current / total;
            //更新播放进度条
            weakSelf.playingProgressView.progress = progress;
        }
    }];

}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
            {
                self.stateLabel.text = @"未知转态";
                NSLog(@"未知转态");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                self.stateLabel.text = @"准备播放";
                NSLog(@"准备播放");
            }
                break;
            case AVPlayerStatusFailed:
            {
                self.stateLabel.text = @"加载失败";
                NSLog(@"加载失败");
            }
                break;
                
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray * timeRanges = self.player.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲
        self.loadingProgressView.progress = scale;
    }
}

//移除监听音乐播放进度
-(void)removeTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

//移除监听音乐缓冲状态
-(void)removePlayLoadTime
{
    if (self.player.currentItem != nil){
        [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
}

//移除监听播放器状态
-(void)removePlayStatus
{
    if (self.player.currentItem != nil){
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
}


-(void)dealloc{
    [self removeTimeObserver];
    [self removePlayLoadTime];
    [self removePlayStatus];
    [self.player pause];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

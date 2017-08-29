//
//  HYPlayerTool.m
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPlayerTool.h"
#import "HYMusic.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface HYPlayerTool()


@end

@implementation HYPlayerTool

+ (instancetype)sharePlayerTool {
    static HYPlayerTool *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[HYPlayerTool alloc] init];
    });
    return player;
}

- (instancetype)init {
    if (self = [super init]) {
        self.aPlayer = [[AVQueuePlayer alloc] init];
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    return self;
}

- (void)playMusicAtIndex:(NSInteger)index{
    _currentIndex = index;
    [self setupPlayerWithModel:[_dataSourceArr objectAtIndex:index]];
}

- (void)setupPlayerWithModel:(HYMusic *)model  {
    self.currentMusic = model;
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:model.musicUrl]];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [self.aPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    self.isPlaying = YES;
    [self.aPlayer play];
    
    //发出播放通知
    [[NSNotificationCenter defaultCenter] postNotificationName:HYPlayerToolMusicBeginPlay object:model];
    
    //播放进度监听
    if(self.playerTimer){
        [self.playerTimer invalidate];
    }
    self.playerTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleActionTime:) userInfo:_playerItem repeats:YES];
    
    //锁屏信息
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"openword_bg"]];

    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyTitle : model.songName,
                                  MPMediaItemPropertyArtist : @"歌手",
                                  MPMediaItemPropertyPlaybackDuration : @(240),
                                  MPNowPlayingInfoPropertyElapsedPlaybackTime : @(0),
                                  MPMediaItemPropertyArtwork : artwork
                                  };
    
}


- (void)stop{
    [self.aPlayer pause];
    [self.aPlayer replaceCurrentItemWithPlayerItem:nil];
    _playerItem = nil;
    _currentMusic = nil;
    _currentIndex = -1;
    _albumId = 0;
    //清除锁屏信息
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    infoCenter.nowPlayingInfo = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:HYPlayerToolMusicStop object:_currentMusic];
}

-(void)pause{
    [self.aPlayer pause];
    self.isPlaying = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:HYPlayerToolMusicPause object:_currentMusic];
}

-(void)play{
    if(self.aPlayer.currentItem == nil){
        if (self.dataSourceArr.count > 0) {
            [self playMusicAtIndex:0];
        }
        return;
    }
    
    [self.aPlayer play];
    self.isPlaying = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:HYPlayerToolMusicBeginPlay object:_currentMusic];
}

- (void)seekTo:(CGFloat)percent{

    [self.aPlayer pause];
    float time = percent * CMTimeGetSeconds(self.aPlayer.currentItem.duration);
    [self.aPlayer seekToTime:CMTimeMake(time, 1) completionHandler:^(BOOL finished) {
        [self.aPlayer play];
    }];
}

- (BOOL)playNext{
    if (_currentIndex == _dataSourceArr.count-1) {
        return NO;
    }
    [self nextSong];
    return YES;
}

- (BOOL)playPre{
    if (_currentIndex == 0) {
        return NO;
    }
    [self preSong];
    return YES;
}

-(NSInteger)currentTime{
    return CMTimeGetSeconds(self.playerItem.currentTime);
}

-(NSInteger)durationTime{
    return CMTimeGetSeconds(self.playerItem.duration);
}

-(CGFloat)currentPercent{
    return ((float)self.currentTime)/self.durationTime;
}

-(NSString*)currentTimeStr{
    return  [self timeformatFromSeconds:self.currentTime];
}

-(NSString*)durationTimeStr{
    return  [self timeformatFromSeconds:self.durationTime];
}

//播放下一首歌曲
- (void)nextSong {
    //将上一个Item置为nil， 为下一个播放做准备
    self.playerItem = nil;
    if (++_currentIndex >= _dataSourceArr.count) {
//        _currentIndex = 0;
//        [self setupPlayerWithModel:[_dataSourceArr firstObject]];
    } else {
        [self setupPlayerWithModel:_dataSourceArr[_currentIndex]];
    }
}

//播放上一首歌曲
- (void)preSong {
    //将上一个Item置为nil， 为下一个播放做准备
    self.playerItem = nil;
    if (--_currentIndex < 0) {
//        _currentIndex = _dataSourceArr.count-1;
//        [self setupPlayerWithModel:[_dataSourceArr lastObject]];
    } else {
        [self setupPlayerWithModel:_dataSourceArr[_currentIndex]];
    }
}

- (void)handleActionTime:(NSTimer *)timer {
    AVPlayerItem *newItem = (AVPlayerItem *)timer.userInfo;
    if ([newItem status] == AVPlayerStatusReadyToPlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HYPlayerToolMusicTimeUpdate object:nil];

    }
}

//歌曲播放完后处理事件
- (void)playerItemAction:(AVPlayerItem *)item {
    [self.playerTimer invalidate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextSong];
    });
}


#pragma mark - Private method
//时间格式化
- (NSString *)timeformatFromSeconds:(NSInteger)seconds {
    NSInteger totalm = seconds/(60);
    NSInteger h = totalm/(60);
    NSInteger m = totalm%(60);
    NSInteger s = seconds%(60);
    if (h == 0) {
        return  [NSString stringWithFormat:@"%02ld:%02ld", (long)m, (long)
                 s];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
}



@end

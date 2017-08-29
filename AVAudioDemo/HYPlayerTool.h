//
//  HYPlayerTool.h
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define HYPlayerToolMusicTimeUpdate @"HYPlayerToolMusicTimeUpdate"
#define HYPlayerToolMusicBeginPlay @"HYPlayerToolMusicBeginPlay"
#define HYPlayerToolMusicPause @"HYPlayerToolMusicPause"
#define HYPlayerToolMusicStop @"HYPlayerToolMusicStop"

@class HYMusic;

@interface HYPlayerTool : NSObject

@property (nonatomic, strong) AVQueuePlayer *aPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;  //当前播放的Item
@property (nonatomic, strong) NSMutableArray<HYMusic*> *dataSourceArr; //当前播放的数据源
@property(nonatomic,assign) NSInteger currentIndex;//当前播放序列
@property(nonatomic,assign) BOOL isPlaying;//是否正在播放
@property(nonatomic,assign) NSInteger currentTime;//已播放时长
@property(nonatomic,assign) NSInteger durationTime;//总时长
@property(nonatomic,assign) CGFloat currentPercent;//已播放比例
@property(nonatomic,strong) NSString *currentTimeStr;//已播放时长字符串
@property(nonatomic,strong) NSString *durationTimeStr;//总时长字符串
@property(nonatomic,strong) HYMusic *currentMusic;//当前播放的music模型
@property(nonatomic,assign) NSInteger albumId;//当前播放的专辑id
//1-每日开场白为 2-最新  3-排行
@property (nonatomic, strong) NSTimer *playerTimer;

+ (instancetype)sharePlayerTool;

/**
 *  播放第index首
 **/
- (void)playMusicAtIndex:(NSInteger)index;

/**
 *  暂停播放
 **/
- (void)pause;

/**
 *  停止播放
 **/
- (void)stop;

/**
 *  继续播放
 **/
- (void)play;

/**
 *  拖动进度到
 **/
- (void)seekTo:(CGFloat)percent;

/**
 *  播放下一首
 **/
- (BOOL)playNext;

/**
 *  播放上一首
 **/
- (BOOL)playPre;

//锁屏图片
-(void)updateSongImage:(UIImage*)image url:(NSString*)url;


- (NSString *)timeformatFromSeconds:(NSInteger)seconds;

@end

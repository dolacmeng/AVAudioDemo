//
//  HYPlayViewController.m
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import "HYPlayViewController.h"
#import "HYMusic.h"
#import "HYPlayerTool.h"
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>

#define ColorForTheme [UIColor colorWithRed:255.0/255.0 green:112.0/255.0 blue:67.0/255.0 alpha:1]


@interface HYPlayViewController ()

@property (weak, nonatomic) IBOutlet UILabel *vcTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property(nonatomic,assign) BOOL isSeeking;

@end

@implementation HYPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeSlider.thumbTintColor = ColorForTheme;
    self.timeSlider.minimumTrackTintColor = ColorForTheme;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb_normal"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginPlayMusic:) name:HYPlayerToolMusicBeginPlay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayMusicTime:) name:HYPlayerToolMusicTimeUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseMusic:) name:HYPlayerToolMusicPause object:nil];
    
    [self setUpData];
    [self setUpDataWithMusic:[HYPlayerTool sharePlayerTool].currentMusic];
    [self remoteControlEventHandler];
}

-(void)setUpData{
    
    NSMutableArray<HYMusic*> *musicArray = [NSMutableArray array];
    NSArray *urlArray = @[@"http://cc.stream.qqmusic.qq.com/203307067.m4a?fromtag=52",@"http://www.0dutv.com/plug/down/up2.php/103980722.mp3",@"http://www.0dutv.com/plug/down/up2.php/202761967.mp3"];
    for (int i=0; i<urlArray.count; i++) {
        HYMusic *music = [[HYMusic alloc] initWithTitle:[NSString stringWithFormat:@"歌曲%zd",i+1] musicUrl:urlArray[i]];
        [musicArray addObject:music];
    }
    
    [HYPlayerTool sharePlayerTool].dataSourceArr = musicArray;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action
//点击播放
- (IBAction)clickPlay:(UIButton *)sender {
    if ([[HYPlayerTool sharePlayerTool] isPlaying]) {
        [[HYPlayerTool sharePlayerTool] pause];
        [self.playButton setSelected:NO];
    }else{
        [[HYPlayerTool sharePlayerTool] play];
        [self.playButton setSelected:YES];
    }
}

//点击下一曲
- (IBAction)clickNext:(UIButton *)sender {
    if(![[HYPlayerTool sharePlayerTool] playNext]){
        NSLog(@"已是最后一首");
    }
}

//点击上一曲
- (IBAction)clickPre:(UIButton *)sender {
    if(![[HYPlayerTool sharePlayerTool] playPre]){
        NSLog(@"已是第一首");
    }
}


- (IBAction)clickClose:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickList:(UIButton *)sender {
//    HYPlayListViewController *vc = [[HYPlayListViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)didslide:(UISlider *)slider {
    if ([[HYPlayerTool sharePlayerTool] playerItem] == nil) {
        return;
    }
    _isSeeking = YES;
    [[HYPlayerTool sharePlayerTool] pause];
    NSInteger totalSecond =CMTimeGetSeconds([[HYPlayerTool sharePlayerTool] playerItem].duration);
    self.beginTimeLabel.text = [[HYPlayerTool sharePlayerTool] timeformatFromSeconds:slider.value*totalSecond];
}

- (IBAction)slideEnd:(UISlider*)sender {
    if ([[HYPlayerTool sharePlayerTool] playerItem] == nil) {
        sender.value = 0.f;
        return;
    }
    [[HYPlayerTool sharePlayerTool] seekTo:sender.value];
    [[HYPlayerTool sharePlayerTool] play];
    _isSeeking = NO;
}

-(void)beginPlayMusic:(NSNotification*)noti{
    HYMusic *music = noti.object;
    [self setUpDataWithMusic:music];
}

-(void)pauseMusic:(NSNotification*)noti{
    [self.playButton setSelected:NO];
}

-(void)setUpDataWithMusic:(HYMusic*)music{
    HYPlayerTool *tool = [HYPlayerTool sharePlayerTool];

    //歌曲信息
    self.titleLabel.text = music.songName;
//    self.endTimeLabel.text = [tool timeformatFromSeconds:[music.musicSecond integerValue]];
    self.vcTitleLabel.text = [NSString stringWithFormat:@"正在播放%zd/%zd",tool.currentIndex+1,tool.dataSourceArr.count];
    
    [self.playButton setSelected:[[HYPlayerTool sharePlayerTool] isPlaying]];
}

-(void)updatePlayMusicTime:(NSNotification*)noti{
    if (!_isSeeking) {
        HYPlayerTool *tool = [HYPlayerTool sharePlayerTool];
        self.beginTimeLabel.text = tool.currentTimeStr;
        self.timeSlider.value = tool.currentPercent;
    }
}



#pragma mark - 音乐控制
// 在需要处理远程控制事件的具体控制器或其它类中实现
- (void)remoteControlEventHandler
{
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTarget:self action:@selector(playAction:)];
    
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    // 为暂停, 上一曲, 下一曲分别添加对应的响应事件
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAction:)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackAction:)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackAction:)];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPauseAction:)];
}

-(void)playAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] play];
}
-(void)pauseAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] pause];
}
-(void)nextTrackAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] playNext];
}
-(void)previousTrackAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] playPre];
}
-(void)playOrPauseAction:(id)obj{
    if ([[HYPlayerTool sharePlayerTool] isPlaying]) {
        [[HYPlayerTool sharePlayerTool] pause];
    }else{
        [[HYPlayerTool sharePlayerTool] play];
    }
}

@end

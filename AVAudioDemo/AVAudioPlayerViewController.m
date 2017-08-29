//
//  AVAudioPlayerViewController.m
//  AVAudioDemo
//
//  Created by pconline on 2017/8/16.
//  Copyright © 2017年 pconline. All rights reserved.
//

#import "AVAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayerViewController ()

@property(nonatomic,strong) AVAudioPlayer *player;
@property(nonatomic,assign) BOOL isPlaying;
@end

@implementation AVAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //加载本地音乐
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    
    if (self.player) {
        [self.player prepareToPlay];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    button.center = self.view.center;
    [button setTitle:@"播放本地音乐" forState:UIControlStateNormal];
    [button setTitle:@"暂停" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:0];
    [button addTarget:self action:@selector(clickPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.player.volume = 0.5;
    self.player.pan = -1;
    self.player.numberOfLoops = -1;
    self.player.rate = 0.5;
}


- (void)clickPlay:(UIButton*)button{
    
    if(!self.isPlaying){
        [self.player play];
        button.selected = YES;
        self.isPlaying = YES;
    }else{
        [self.player stop];
        button.selected = NO;
        self.isPlaying = NO;
    }
    
}
@end

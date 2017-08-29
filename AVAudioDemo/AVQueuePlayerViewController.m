//
//  AVQueuePlayerViewController.m
//  AVAudioDemo
//
//  Created by pconline on 2017/8/24.
//  Copyright © 2017年 pconline. All rights reserved.
//

#import "AVQueuePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVQueuePlayerViewController ()

@property(nonatomic,strong) NSArray<AVPlayerItem *> *musics;
@property(nonatomic,strong) AVQueuePlayer *player;

@end

@implementation AVQueuePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *musicStringArray = @[@"http://mp3.haoduoge.com/s/2017-08-24/1503559101.mp3",@"http://mp3.haoduoge.com/s/2017-08-23/1503501332.mp3",@"http://mp3.haoduoge.com/s/2017-08-24/1503554791.mp3"];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *musicUrl in musicStringArray) {
        AVPlayerItem *itme = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:musicUrl]];
        [tempArray addObject:itme];
    }
    self.musics = [tempArray copy];
    self.player = [[AVQueuePlayer alloc] initWithItems:self.musics];
    [self.player play];
}

- (void)setUpView {
    
}


@end

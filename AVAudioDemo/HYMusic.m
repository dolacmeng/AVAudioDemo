//
//  HYMusic.m
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import "HYMusic.h"

@implementation HYMusic

-(instancetype)initWithTitle:(NSString*)title musicUrl:(NSString*)musicUrl{
    
    if (self == [super init]) {
        self.songName = title;
        self.musicUrl = musicUrl;
    }

    return self;
}

@end

//
//  HYMusic.h
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYMusic : NSObject

@property (nonatomic, copy) NSString *singerName;
@property(nonatomic,copy) NSString *singerRole;
@property(nonatomic,copy) NSString *accessToken;
@property(nonatomic,strong) NSNumber *singerId;
@property(nonatomic,copy) NSString *avatar;

@property (nonatomic, copy) NSString *songName;
@property(nonatomic,strong) NSNumber *songId;
@property (nonatomic, copy) NSString *logo;//歌曲图片
@property(nonatomic,copy) NSString *date;
@property(nonatomic,strong) NSNumber *musicSecond;//时长
@property (nonatomic, copy) NSString *musicUrl;//歌曲url

-(instancetype)initWithTitle:(NSString*)title musicUrl:(NSString*)musicUrl;

@end

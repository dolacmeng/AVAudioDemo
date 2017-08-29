//
//  ViewController.m
//  AVAudioDemo
//
//  Created by pconline on 2017/8/16.
//  Copyright © 2017年 pconline. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSArray *titleArray;
@property(nonatomic,strong) NSArray *vcArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[@"AVAudioPlayer",@"AVPlayer",@"AVQueuePlayer",@"播放页面"];
    self.vcArray = @[@"AVAudioPlayerViewController",@"AVPlayerViewController",@"AVQueuePlayerViewController",@"HYPlayViewController"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.titleArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *classStr = self.vcArray[indexPath.row];
    Class c = NSClassFromString(classStr);
    UIViewController *vc = [[c alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end

//
//  ViewController.m
//  Blocker
//
//  Created by 倪刚 on 2017/4/29.
//  Copyright © 2017年 倪刚. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define BALL_VELOCITY_Y (-80)

@interface ViewController ()
{
    CADisplayLink *_displayLink;
    CGPoint _ballv; // 小球速度 x：正数向右，负数向左 y：正数向下，负数向上
    
    NSMutableArray *_blocksM; // 砖块可变数组
    
    CGFloat _paddleV; // 挡板速度
    
    CFTimeInterval _paddleInterval;

    CGPoint _oriBallCenter; // 小球初始位置
    CGPoint _oriPaddleCenter; // 单板初始位置
    
    AVAudioPlayer *_player;
}

- (void)handleIntersectWithBlocks;
- (void)handleIntersectWithPaddle;
- (void)handleIntersectWithScreen;

- (void)pausegame;
- (void)resetGame;

- (void)checkWin;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _oriBallCenter = self.ball.center; // 初始化小球位置
    _oriPaddleCenter = self.paddle.center; // 初始化挡板位置
    
    [self resetGame];
}

#pragma mark - private

// 碰撞砖块反弹
- (void)handleIntersectWithBlocks
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGRectIntersectsRect(self.ball.frame, [evaluatedObject frame]);
        
    }];
    
    NSArray *intersectsBlocks = [_blocksM filteredArrayUsingPredicate:predicate];
    
    UIView *block = [intersectsBlocks lastObject];
    if (block) {
        
        //[block setHidden:YES];
        // 从界面上移除
        [block removeFromSuperview];
        
        // 从数组里移除
        [_blocksM removeObject:block];
        
        _ballv.y *= -1;
    }
}

// 挡板碰撞反弹
- (void)handleIntersectWithPaddle
{
    if (CGRectIntersectsRect(self.ball.frame, self.paddle.frame)) {
    
        _ballv.y *= -1;
        
        _ballv.x += _paddleV; // 移动挡板碰到小球给小球x轴一个反向速度
    }
}

// 碰撞屏幕反弹
- (void)handleIntersectWithScreen
{
    if (CGRectGetMinY(self.ball.frame) <= 20)
    {
        _ballv.y *= -1;
    }
    else if (CGRectGetMaxY(self.ball.frame) >= 700) // 触底游戏结束
    {
        // TODO: 游戏结束
        self.msgLabel.text = @"Game Over!";
        
        self.msgLabel.hidden = NO; // 取消隐藏（显示Game over！）
        
        // 游戏暂停
        [self pausegame];
        
        self.tapGR.enabled = YES; // 激活tap手势
        
    }
    else if (CGRectGetMinX(self.ball.frame) <= 0 || CGRectGetMaxX(self.ball.frame) >= 375)
    {
        _ballv.x *= -1;
    }
}

// 游戏暂停
- (void)pausegame
{
    [_displayLink invalidate]; // 暂停
}

// TODO: 游戏重置
- (void)resetGame
{
    // 播放背景音乐
    [self backgroundMusic];
    
    // 初始化页面
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _ballv = CGPointMake(0, BALL_VELOCITY_Y -200); // 小球初始速度
    
    _blocksM = [NSMutableArray arrayWithArray:self.blocks];

    self.tapGR.enabled = NO; // 关掉重置游戏手势
    self.msgLabel.hidden = YES; // 隐藏（隐藏Game over！）
    
    // 重置小球的位置
    self.ball.center = _oriBallCenter;
    
    // 重置挡板的位置
    self.paddle.center = _oriPaddleCenter;
    
    // 重置砖块的位置
    [self.blocks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj];
    }];
}

- (void)backgroundMusic {
    // 设置外放声音
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSError *err;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"background-music" withExtension:@"caf"];
    //        NSURL *url = [[NSBundle mainBundle] URLForResource:@"1368" withExtension:@".mp3"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    // 获取系统的声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat currentVol = audioSession.outputVolume;
    // 设置播放器声音
    _player.volume = currentVol;
    // 设置播放速率
    _player.rate = 1.0;
    // 设置播放次数，负数代表无限循环
    _player.numberOfLoops = -1;
    // 预加载资源
    [_player prepareToPlay];
    
    [_player play];
}

// 监听胜利
- (void)checkWin
{
    if (_blocksM.count == 0) {
        self.msgLabel.text = @"Victory";
        self.msgLabel.hidden = NO;
        
        [self pausegame];
        self.tapGR.enabled = YES; // 激活tap手势
    }
}

#pragma mark - action
- (void)step:(CADisplayLink *)sender
{
    CGFloat duration = (sender.timestamp - _paddleInterval)/1000; // 挡板x轴运动的时间
    
    //NSLog(@"%@", sender);
    //self.ball.center = CGPointMake(self.ball.center.x + _ballv.x * duration * 0.1, self.ball.center.y + _ballv.y * sender.duration);

    self.ball.center = CGPointMake(self.ball.center.x + _ballv.x * duration, self.ball.center.y + _ballv.y * sender.duration);

    //NSLog(@"_ballv is %@",NSStringFromCGPoint(_ballv)); // 打印当前小球速度
    if (_ballv.x >= 6000) // 把小球速度限制在20000以下
    {
        _ballv.x -= 100;
    }

    [self handleIntersectWithBlocks]; // 碰撞砖块消除
    [self handleIntersectWithPaddle]; // 碰撞挡板反弹
    [self handleIntersectWithScreen]; // 碰撞屏幕反弹
    
    [self checkWin]; // 监听游戏是否胜利
}

// 移动滑板的手势
- (IBAction)onPaddlePan:(UIPanGestureRecognizer *)sender {
    
    NSLog(@"%@", NSStringFromCGPoint([sender translationInView:self.view]));
    
    static CGPoint originalcenter;
    if (UIGestureRecognizerStateBegan == sender.state) {
        originalcenter = self.paddle.center;
    }
    
    CGPoint trans = [sender translationInView:self.view];
    if (UIGestureRecognizerStateChanged == sender.state) {
        self.paddle.center = CGPointMake(trans.x + originalcenter.x, self.paddle.center.y);
        
        _paddleV = [sender velocityInView:self.view].x;
        _paddleInterval = _displayLink.timestamp;
    }
    
}

// 点击屏幕的手势
- (IBAction)onTapScreen:(id)sender {
    NSLog(@"tap screen");
    [self resetGame];
}
@end


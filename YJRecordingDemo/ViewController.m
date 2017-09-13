//
//  ViewController.m
//  YJRecordingDemo
//
//  Created by Joye on 2017/9/12.
//  Copyright © 2017年 YJ. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) NSURL *recordFileUrl;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) int recordTime;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(60, 100, 100, 30)];
    [button setTitle:@"start" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 100, 100, 30)];
    [stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stopBtn.backgroundColor = [UIColor yellowColor];
    [stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    
    UIButton *playbtn = [[UIButton alloc] init];
    playbtn.backgroundColor = [UIColor yellowColor];
    [playbtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playbtn];
    self.playBtn = playbtn;
}


- (void)startBtnClick
{
    _recordTime = 0;
    _playBtn.frame = CGRectMake(60, 150, 0, 30);
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getRecordingTime) userInfo:nil repeats:YES];
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session) {
        [session setActive:YES error:nil];
    }else {
        NSLog(@"create session failure---%@",[sessionError description]);
    }
    
    self.session = session;
    
    // 获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 设置文件路径
    _filePath = [path stringByAppendingString:@"/yj_record.wav"];
    self.recordFileUrl = [NSURL fileURLWithPath:_filePath];
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    
    if (_recorder) {
        
        NSLog(@"开始录音");
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化recorder");
    }
}


- (void)playBtnClick
{
    NSLog(@"播放录音");
    [_timer invalidate];
    _timer = nil;
    [self.recorder stop];
    
    if ([self.player isPlaying])return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    
//    NSLog(@"%li",self.player.data.length/1024);
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}


- (void)stopBtnClick
{
    [self removeTimer];
    NSLog(@"停止录音");
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_filePath]) {
        
        _playBtn.frame = CGRectMake(60, 150, _recordTime+10, 30);
        
    }else{
        NSLog(@"录音失败");
    }
    _recordTime = 0;
}

- (void)getRecordingTime
{
    _recordTime ++;
    NSLog(@"rt--%d",_recordTime);
    if (_recordTime >= 60) {
        [self stopBtnClick];
    }
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

/*
 1.添加AVFoundation的依赖库
 2.导入AVFoundation的头文件
 3.设置文件格式进行录音
 */
@end

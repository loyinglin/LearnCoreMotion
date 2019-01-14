//
//  ViewController.m
//  LearnCoreMotion
//
//  Created by loyinglin on 2019/1/10.
//  Copyright © 2019 ByteDance. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "UIView+LYLayout.h"

static CGFloat lySlowLowPassFilter(NSTimeInterval elapsed,
                            GLfloat target,
                            GLfloat current)
{
    return current + (4.0 * elapsed * (target - current));
}


#define kConstBallLength (50)

typedef NS_ENUM(NSUInteger, LYGameStatus) {
    LYGameStatusReady,
    LYGameStatusRunning,
};

#define kConstGameTime (30)

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) UIView *ballView;

@property (nonatomic, strong) CADisplayLink *displayLink;

// game
@property (nonatomic, assign) LYGameStatus gameStatus;
@property (nonatomic, assign) NSUInteger gamePoint;
@property (nonatomic, strong) NSDate *gameStartDate;

@property (nonatomic, assign) CGFloat ballSpeedX;
@property (nonatomic, assign) CGFloat ballSpeedY;
@property (nonatomic, strong) NSDate *ballLastUpdateDate;

//
@property (nonatomic, strong) IBOutlet UILabel *gameScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameStatusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customInitViews];
    
    // timer
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    // game reset
    [self resetGame];
    
    // motion
    [self startMotionUpdate];
}

- (void)startMotionUpdate {
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60;
    [self.motionManager startDeviceMotionUpdates];
}


#pragma mark - init

- (void)customInitViews {
    self.ballView.center = self.view.center;
    [self.view insertSubview:self.ballView atIndex:0];
    
    self.gameStatusLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.gameStatusLabel addGestureRecognizer:tap];
    
}

#pragma mark - action

- (void)onTap {
    if (self.gameStatus == LYGameStatusReady) {
        [self startGame];
    }
}

- (void)logicUpdate {
    if (self.gameStatus == LYGameStatusRunning) { // running
        NSDate *date = [NSDate date];
        NSTimeInterval gameTime = [date timeIntervalSinceDate:self.gameStartDate];
        if (gameTime < kConstGameTime) {
            // updateUI
            self.gameScoreLabel.text = [NSString stringWithFormat:@"分数:%lu分", self.gamePoint];
            self.gameStatusLabel.text = [NSString stringWithFormat:@"剩余时间：%.1f", (kConstGameTime - gameTime)];
            
            [self updateLocationWithAcceleration:self.motionManager.deviceMotion.gravity];
        }
        else {
            // gameOver
            [self resetGame];
        }
    }
}

#pragma mark - gameLogic

- (void)startGame {
    self.gameStatus = LYGameStatusRunning;
    self.ballView.center = self.view.center;
    self.gameStartDate = [NSDate date];
    [self.displayLink setPaused:NO];
}

- (void)resetGame {
    self.gameStatusLabel.text = @"开始";
    [self.displayLink setPaused:YES];
    self.gameStatus = LYGameStatusReady;
    self.ballLastUpdateDate = nil;
}

- (void)updateLocationWithAcceleration:(CMAcceleration)accelleration {
    if (self.ballLastUpdateDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.ballLastUpdateDate];
        
        self.ballSpeedX = lySlowLowPassFilter(timeInterval, accelleration.x, self.ballSpeedX);
        self.ballSpeedY = lySlowLowPassFilter(timeInterval, accelleration.y, self.ballSpeedY);
        
        self.ballView.centerX += self.ballSpeedX * 100;
        self.ballView.centerY -= self.ballSpeedY * 100;
    }
    self.ballLastUpdateDate = [NSDate date];
//    //    更新时间
    if (self.ballView.left < 0) {
        self.ballView.left = 0;
        self.ballSpeedX /= -1;
    }

    if (self.ballView.right > self.view.width) {
        self.ballView.right = self.view.width;
        self.ballSpeedX /= -1;
    }

    if (self.ballView.top < 0) {
        self.ballView.top = 0;
        self.ballSpeedY /= -1;
    }

    if (self.ballView.bottom >= self.view.height) {
        self.ballView.bottom = self.view.height;
        self.ballSpeedY /= -1;
    }
}

#pragma mark - gettet

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

- (UIView *)ballView {
    if (!_ballView) {
        _ballView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kConstBallLength, kConstBallLength)];
        _ballView.ssCornerRadius = _ballView.width / 2;
        _ballView.backgroundColor = [UIColor redColor];
    }
    return _ballView;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(logicUpdate)];
    }
    return _displayLink;
}

@end


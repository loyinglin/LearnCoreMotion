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
                            GLfloat current) {
    return current + (4.0 * elapsed * (target - current));
}


#define kConstBallLength (50)
#define kConstTargetLength (10)

typedef NS_ENUM(NSUInteger, LYGameStatus) {
    LYGameStatusReady,
    LYGameStatusRunning,
};

#define kConstGameTime (30)

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIView *ballView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) CADisplayLink *displayLink;

// game
@property (nonatomic, assign) LYGameStatus gameStatus;
@property (nonatomic, assign) NSUInteger gameScore;
@property (nonatomic, strong) NSDate *gameStartDate;

@property (nonatomic, assign) CGFloat ballSpeedX;
@property (nonatomic, assign) CGFloat ballSpeedY;
@property (nonatomic, strong) NSDate *ballLastUpdateDate;

//
@property (nonatomic, strong) IBOutlet UILabel *gameScoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameStatusLabel;
@property (nonatomic, strong) IBOutlet UIView *gameContainerView;

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
    [self.gameContainerView addSubview:self.ballView];
    
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
            self.gameScoreLabel.text = [NSString stringWithFormat:@"分数:%lu分", self.gameScore];
            self.gameStatusLabel.text = [NSString stringWithFormat:@"剩余时间：%.1f", (kConstGameTime - gameTime)];
            
            [self updateLocationWithAcceleration:self.motionManager.deviceMotion.gravity]; // self.motionManager.deviceMotion
            
            if ([self checkTarget]) {
                self.gameScore++;
                [self generateTargetView];
            }
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
    self.gameScore = 0;
    self.ballView.center = self.view.center;
    self.gameStartDate = [NSDate date];
    [self.displayLink setPaused:NO];
    [self generateTargetView];
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

    if (self.ballView.left < 0) {
        self.ballView.left = 0;
        self.ballSpeedX /= -1;
    }

    if (self.ballView.right > self.gameContainerView.width) {
        self.ballView.right = self.gameContainerView.width;
        self.ballSpeedX /= -1;
    }

    if (self.ballView.top < 0) {
        self.ballView.top = 0;
        self.ballSpeedY /= -1;
    }

    if (self.ballView.bottom >= self.gameContainerView.height) {
        self.ballView.bottom = self.gameContainerView.height;
        self.ballSpeedY /= -1;
    }
}

- (void)generateTargetView {
    [self.gameContainerView addSubview:self.targetView];
    
    do {
        self.targetView.center = CGPointMake(arc4random_uniform((int)self.gameContainerView.width - 2 * kConstTargetLength),
                                             arc4random_uniform((int)self.gameContainerView.height - 2 * kConstTargetLength));
        if ([self checkTarget]) {
            continue;
        }
    }while (false);
}

- (BOOL)checkTarget {
    CGFloat disX = (self.ballView.centerX - self.targetView.centerX);
    CGFloat disY = (self.ballView.centerY - self.targetView.centerY);
    return sqrt(disX * disX + disY * disY) <= (kConstBallLength / 2 + kConstTargetLength / 2);
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

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kConstTargetLength, kConstTargetLength)];
        _targetView.ssCornerRadius = _targetView.width / 2;
        _targetView.backgroundColor = [UIColor yellowColor];
    }
    return _targetView;
}

@end


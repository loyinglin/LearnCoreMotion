//
//  ViewController.m
//  LearnCoreMotion
//
//  Created by loyinglin on 2019/1/10.
//  Copyright © 2019 ByteDance. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image"]];
    self.imageView.center = self.view.center;
    [self.view addSubview:self.imageView];
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    
    [self start];
}

- (void)start {
//    if (![self.motionManager isDeviceMotionActive] && [self.motionManager isDeviceMotionAvailable]) {
//        self.motionManager.deviceMotionUpdateInterval = 0.5;
//        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
//                                                withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//                                                    CMAcceleration gravity = motion.gravity;
//                                                    NSLog(@"地球重力, x:%lf, y:%lf, z%lf", gravity.x, gravity.y, gravity.z);
//
//                                                    CMAcceleration userAcceleration = motion.userAcceleration;
//                                                    NSLog(@"手机陀螺仪, x:%lf, y:%lf, z%lf", userAcceleration.x, userAcceleration.y, userAcceleration.z);
//
//
//
//                                                    NSLog(@"真正加速度, x:%lf, y:%lf, z%lf", userAcceleration.x + gravity.x,
//                                                          userAcceleration.y + gravity.y, userAcceleration.z + gravity.z);
//
//
//                                                    NSLog(@"\n\n");
//
//                                                }];
//    }

//    if (self.motionManager.accelerometerAvailable) {
//        self.motionManager.accelerometerUpdateInterval = 0.05;
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
//                                                 withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//                                                     double rotation = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y) - M_PI;
//                                                     self.imageView.transform = CGAffineTransformMakeRotation(rotation);
//                                                 }];
//    }
    
//    if (self.motionManager.gyroAvailable) {
//        self.motionManager.gyroUpdateInterval = 0.5;
//        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
//                                        withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
//                                            if (error) {
//                                                [self.motionManager stopGyroUpdates];
//                                                NSLog(@"There is something error for accelerometer update");
//                                            }else {
//                                                NSLog(@"\n旋转速度：\nX: %f\nY: %f\nZ: %f", gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z);
//                                            }
//        }];
//    }
}

@end

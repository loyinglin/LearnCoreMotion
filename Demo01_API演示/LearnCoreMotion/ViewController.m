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
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.imageView.image = [UIImage imageNamed:@"Image"];
    self.imageView.center = self.view.center;
    [self.view addSubview:self.imageView];
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    
    [self start];
}

- (void)start {
    if (![self.motionManager isDeviceMotionActive] && [self.motionManager isDeviceMotionAvailable]) {
        self.motionManager.deviceMotionUpdateInterval = 0.2;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                                    CMAcceleration gravity = motion.gravity;
//                                                    NSLog(@"地球重力, x:%lf, y:%lf, z%lf", gravity.x, gravity.y, gravity.z);

//                                                    CMAcceleration userAcceleration = motion.userAcceleration;
//                                                    NSLog(@"手机加速度, z%.2f", userAcceleration.z);

                                                    CMRotationRate rotaionRate = motion.rotationRate;
                                                    NSLog(@"陀螺仪, x:%.2lf, y:%.2lf, z%.2lf", rotaionRate.x, rotaionRate.y, rotaionRate.z);

                                                    double rotation = atan2(gravity.x, gravity.y) - M_PI;
                                                    self.imageView.transform = CGAffineTransformMakeRotation(rotation);
  
                                                }];
    }
}

- (void)anotherWay {
    if (self.motionManager.accelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = 0.05;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                 withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                                     double rotation = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y) - M_PI;
                                                     self.imageView.transform = CGAffineTransformMakeRotation(rotation);
                                                 }];
    }
    
    if (self.motionManager.gyroAvailable) {
        self.motionManager.gyroUpdateInterval = 0.5;
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                        withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                                            if (error) {
                                                [self.motionManager stopGyroUpdates];
                                                NSLog(@"There is something error for accelerometer update");
                                            }else {
                                                NSLog(@"\n旋转速度：\nX: %f\nY: %f\nZ: %f", gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z);
                                            }
                                        }];
    }
    
    if (self.motionManager.magnetometerAvailable) {
        self.motionManager.magnetometerUpdateInterval = 0.5;
        [self.motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
                                                    if (error) {
                                                        [self.motionManager stopMagnetometerUpdates];
                                                    }else{
                                                        NSLog(@"磁力计 X: %f，Y: %f，Z: %f",magnetometerData.magneticField.x,magnetometerData.magneticField.y,magnetometerData.magneticField.z);
                                                    }
                                                }];
    }
}

@end

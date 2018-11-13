//
//  QiScanQRCodeViewController.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiScanQRCodeViewController.h"
#import "QiScanQRCodeManager.h"
#import "QiScanQRCodeView.h"

@interface QiScanQRCodeViewController ()

@property (nonatomic, strong) QiScanQRCodeView *scanView;
@property (nonatomic, strong) QiScanQRCodeManager *manager;

@end

@implementation QiScanQRCodeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _scanView = [[QiScanQRCodeView alloc] initWithFrame:self.view.bounds];
    _scanView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scanView];
    
    _manager = [[QiScanQRCodeManager alloc] initWithPreviewView:_scanView rectFrame:_scanView.rectFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self startScanning];
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private functions

- (void)startScanning {
    
    [_scanView startScanningAnimation];
    
    __weak typeof(self) weakSelf = self;
    [_manager startScanningWithCallback:^(NSString * _Nonnull code) {
        NSLog(@"code is %@", code);
        [weakSelf stopScanning];
    }];
}

- (void)stopScanning {
    
    [_manager stopScanning];
    [_scanView stopScanningAnimation];
}



#pragma mark - Notification functions

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [self stopScanning];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self startScanning];
}

@end

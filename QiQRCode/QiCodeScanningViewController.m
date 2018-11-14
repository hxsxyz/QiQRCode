//
//  QiCodeScanningViewController.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiCodeScanningViewController.h"
#import "QiCodeGenerationViewController.h"
#import "QiCodeScanningView.h"
#import "QiCodeManager.h"

@interface QiCodeScanningViewController ()

@property (nonatomic, strong) QiCodeScanningView *scanView;
@property (nonatomic, strong) QiCodeManager *manager;

@end

@implementation QiCodeScanningViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _scanView = [[QiCodeScanningView alloc] initWithFrame:self.view.bounds];
    _scanView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scanView];
    
    _manager = [[QiCodeManager alloc] initWithPreviewView:_scanView rectFrame:_scanView.rectFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopScanning];
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
        [weakSelf stopScanning];
        [weakSelf performSegueWithIdentifier:@"showCodeGeneration" sender:code];
    }];
    
    [_manager observeLightDimmed:^(BOOL dimmed) {
        [QiCodeManager switchTorch:YES];
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCodeGeneration"]) {
        QiCodeGenerationViewController *codeGeneration = segue.destinationViewController;
        codeGeneration.code = (NSString *)sender;
    }
}

@end

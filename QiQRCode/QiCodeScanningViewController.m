//
//  QiCodeScanningViewController.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiCodeScanningViewController.h"
#import "QiCodeGenerationViewController.h"
#import "QiCodePreviewView.h"
#import "QiCodeManager.h"

@interface QiCodeScanningViewController () <QiCodePreviewViewDelegate>

@property (nonatomic, strong) QiCodePreviewView *previewView;
@property (nonatomic, strong) QiCodeManager *codeManager;

@end

@implementation QiCodeScanningViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _previewView = [[QiCodePreviewView alloc] initWithFrame:self.view.bounds rectColor:[UIColor blueColor]];
    _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _previewView.delegate = self;
    [self.view addSubview:_previewView];
    
    [_previewView startRunningIndicator:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_codeManager) {
        [self startScanning];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!_codeManager) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.codeManager = [[QiCodeManager alloc] initWithPreviewView:self.previewView];
            [self.previewView startRunningIndicator:NO];
            [self startScanning];
        });
    }
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
    
    [_previewView startScanningAnimation:YES];
    
    __weak typeof(self) weakSelf = self;
    [_codeManager startScanningWithCallback:^(NSString * _Nonnull code) {
        [weakSelf performSegueWithIdentifier:@"showCodeGeneration" sender:code];
    } autoStop:YES];
    
    [_codeManager observeLightStatus:^(BOOL dimmed, BOOL torchOn) {
        [weakSelf.previewView showTorchSwithButton:(dimmed || torchOn)];
        [weakSelf.previewView startScanningAnimation:(!dimmed && !torchOn)];
    }];
}

- (void)stopScanning {
    
    [_codeManager stopScanning];
    [_previewView startScanningAnimation:NO];
}


#pragma mark - Notification functions

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [self stopScanning];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self startScanning];
}


#pragma mark - QiCodePreviewViewDelegate

- (void)codeScanningView:(QiCodePreviewView *)scanningView didClickedTorchSwitch:(UIButton *)switchButton {
    
    switchButton.selected = !switchButton.selected;
    
    [QiCodeManager switchTorch:switchButton.selected];
    _codeManager.lightStatusHasCalled = switchButton.selected;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCodeGeneration"]) {
        QiCodeGenerationViewController *codeGeneration = segue.destinationViewController;
        codeGeneration.code = (NSString *)sender;
    }
}

@end

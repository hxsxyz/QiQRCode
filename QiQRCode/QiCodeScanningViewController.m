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

@interface QiCodeScanningViewController ()

@property (nonatomic, strong) QiCodePreviewView *previewView;
@property (nonatomic, strong) QiCodeManager *codeManager;

@end

@implementation QiCodeScanningViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _previewView = [[QiCodePreviewView alloc] initWithFrame:self.view.bounds];
    _previewView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_previewView];
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
            [self startScanning];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_codeManager stopScanning];
}


#pragma mark - Private functions

- (void)startScanning {
    
    __weak typeof(self) weakSelf = self;
    [_codeManager startScanningWithCallback:^(NSString * _Nonnull code) {
        [weakSelf performSegueWithIdentifier:@"showCodeGeneration" sender:code];
    } autoStop:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCodeGeneration"]) {
        QiCodeGenerationViewController *codeGeneration = segue.destinationViewController;
        codeGeneration.code = (NSString *)sender;
    }
}

@end

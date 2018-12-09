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

@interface QiCodeScanningViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) QiCodePreviewView *previewView;
@property (nonatomic, strong) QiCodeManager *codeManager;

@end

@implementation QiCodeScanningViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *photoItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photo:)];
    self.navigationItem.rightBarButtonItem = photoItem;
    
    _previewView = [[QiCodePreviewView alloc] initWithFrame:self.view.bounds];
    _previewView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_previewView];
    
    __weak typeof(self) weakSelf = self;
    _codeManager = [[QiCodeManager alloc] initWithPreviewView:_previewView completion:^{
        [weakSelf startScanning];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_codeManager stopScanning];
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
}


#pragma mark - Action functions

- (void)photo:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [_codeManager presentPhotoLibraryWithRooter:self callback:^(NSString * _Nonnull code) {
        [weakSelf performSegueWithIdentifier:@"showCodeGeneration" sender:code];
    }];
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

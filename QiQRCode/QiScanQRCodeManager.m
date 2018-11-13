//
//  QiScanQRCodeManager.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiScanQRCodeManager.h"
#import <AVFoundation/AVFoundation.h>

@interface QiScanQRCodeManager () <AVCaptureMetadataOutputObjectsDelegate>

//@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, copy) void(^callback)(NSString *);
@property (nonatomic, assign) BOOL autoStop;

@end

@implementation QiScanQRCodeManager

- (instancetype)initWithPreviewView:(UIView *)previewView rectFrame:(CGRect)rectFrame {
    
    self = [super init];
    
    if (self) {
        
        AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:nil];
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        CGFloat x = rectFrame.origin.x / previewView.bounds.size.width;
        CGFloat y = rectFrame.origin.y / previewView.bounds.size.height;
        CGFloat w = rectFrame.size.width / previewView.bounds.size.width;
        CGFloat h = rectFrame.size.height / previewView.bounds.size.height;
        output.rectOfInterest = (CGRect){y, x, h, w};
        
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        if ([_session canAddInput:input]) {
            [_session addInput:input];
        }
        if ([_session canAddOutput:output]) {
            [_session addOutput:output];
            output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code];
        }
        
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = previewView.layer.bounds;
        [previewView.layer insertSublayer:previewLayer atIndex:0];
    }
    
    return self;
}


#pragma mark - Public functions

- (void)startScanningWithCallback:(void (^)(NSString * _Nonnull))callback {
    
    [self startScanningWithCallback:callback autoStop:NO];
}

- (void)startScanningWithCallback:(void (^)(NSString * _Nonnull))callback autoStop:(BOOL)autoStop {
    
    _callback = callback;
    _autoStop = autoStop;
    
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stopScanning {
    
    if (_session.isRunning) {
        [_session stopRunning];
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    AVMetadataMachineReadableCodeObject *code = metadataObjects.firstObject;
    
    if (code.stringValue) {
        if (_autoStop) {
            [self stopScanning];
        }
        if (_callback) {
            _callback(code.stringValue);
        }
    }
}

@end

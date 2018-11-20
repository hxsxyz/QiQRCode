//
//  QiCodeManager.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiCodeManager.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

static NSString *QiInputCorrectionLevelL = @"L";//!< L: 7%
static NSString *QiInputCorrectionLevelM = @"M";//!< M: 15%
static NSString *QiInputCorrectionLevelQ = @"Q";//!< Q: 25%
static NSString *QiInputCorrectionLevelH = @"H";//!< H: 30%

@interface QiCodeManager () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, copy) void(^lightStatus)(BOOL, BOOL);
@property (nonatomic, copy) void(^callback)(NSString *);
@property (nonatomic, assign) BOOL autoStop;

@end

@implementation QiCodeManager

#pragma mark - 扫描二维码/条形码

- (instancetype)initWithPreviewView:(QiCodePreviewView *)previewView {
    
    return [[QiCodeManager alloc] initWithPreviewView:previewView rectFrame:previewView.rectFrame];
}

- (instancetype)initWithPreviewView:(UIView *)previewView rectFrame:(CGRect)rectFrame {
    
    self = [super init];
    
    if (self) {
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
        imageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
        
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        if ([_session canAddInput:deviceInput]) {
            [_session addInput:deviceInput];
        }
        if ([_session canAddOutput:metadataOutput]) {
            [_session addOutput:metadataOutput];
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code];
        }
        if ([_session canAddOutput:imageOutput]) {
            [_session addOutput:imageOutput];
        }
        
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        previewLayer.frame = previewView.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [previewView.layer insertSublayer:previewLayer atIndex:0];
        
        // 设置扫码区域
        if (!CGRectEqualToRect(rectFrame, CGRectZero)) {
            CGFloat x = rectFrame.origin.y / previewView.bounds.size.height;
            CGFloat y = (previewView.bounds.size.width - rectFrame.origin.x - rectFrame.size.width) / previewView.bounds.size.width;
            CGFloat w = rectFrame.size.height / previewView.bounds.size.height;
            CGFloat h = rectFrame.size.width / previewView.bounds.size.width;
            metadataOutput.rectOfInterest = CGRectMake(x, y, w, h);
        }
        
        // 可以在[session startRunning];之后用此语句设置扫码区域
        // metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:rectFrame];
        
        // 设置设备附加属性
        [device lockForConfiguration:nil];
        if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        [device unlockForConfiguration];
        
        // 缩放手势
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pin:)];
        [previewView addGestureRecognizer:pinGesture];
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
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
    [QiCodeManager resetZoomFactor];
    [QiCodeManager switchTorch:NO];
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


#pragma mark - 生成二维码/条形码

//! 生成二维码
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size {
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator" withInputParameters:@{@"inputMessage": codeData, @"inputCorrectionLevel": QiInputCorrectionLevelH}];
    UIImage *codeImage = [QiCodeManager scaleImage:filter.outputImage toSize:size];
    
    return codeImage;
}

//! 生成二维码+logo
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(nonnull UIImage *)logo {
    
    UIImage *codeImage = [QiCodeManager generateQRCode:code size:size];
    codeImage = [QiCodeManager combinateCodeImage:codeImage andLogo:logo];
    
    return codeImage;
}

//! 生成条形码
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size {
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator" withInputParameters:@{@"inputMessage": codeData, @"inputQuietSpace": @.0}];
    /* @{@"inputMessage": codeData, @"inputQuietSpace": @(.0), @"inputBarcodeHeight": @(size.width / 3)} */
    UIImage *codeImage = [QiCodeManager scaleImage:filter.outputImage toSize:size];
    
    return codeImage;
}


#pragma mark - Util functions

// 缩放图片(生成高质量图片）
+ (UIImage *)scaleImage:(CIImage *)image toSize:(CGSize)size {
    
    //! 将CIImage转成CGImageRef
    CGRect integralRect = image.extent;// CGRectIntegral(image.extent);// 将rect取整后返回，origin取舍，size取入
    CGImageRef imageRef = [[CIContext context] createCGImage:image fromRect:integralRect];
    
    //! 创建上下文
    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * [UIScreen mainScreen].scale;// 计算需要缩放的比例
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, CGColorSpaceCreateDeviceGray(), (CGBitmapInfo)kCGImageAlphaNone);// 灰度、不透明
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);// 设置上下文无插值
    CGContextScaleCTM(contextRef, sideScale, sideScale);// 设置上下文缩放
    CGContextDrawImage(contextRef, integralRect, imageRef);// 在上下文中的integralRect中绘制imageRef
    
    //! 从上下文中获取CGImageRef
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    
    //! 将CGImageRefc转成UIImage
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    return scaledImage;
}

// 合成图片（code+logo）
+ (UIImage *)combinateCodeImage:(UIImage *)codeImage andLogo:(UIImage *)logo {
    
    UIGraphicsBeginImageContextWithOptions(codeImage.size, YES, [UIScreen mainScreen].scale);
    
    // 将codeImage画到上下文中
    [codeImage drawInRect:(CGRect){.0, .0, codeImage.size.width, codeImage.size.height}];
    
    // 定义logo的绘制参数
    CGFloat logoSide = fminf(codeImage.size.width, codeImage.size.height) / 4;
    CGFloat logoX = (codeImage.size.width - logoSide) / 2;
    CGFloat logoY = (codeImage.size.height - logoSide) / 2;
    CGRect logoRect = (CGRect){logoX, logoY, logoSide, logoSide};
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:logoRect cornerRadius:logoSide / 5];
    [cornerPath setLineWidth:2.0];
    [[UIColor whiteColor] set];
    [cornerPath stroke];
    [cornerPath addClip];
    
    // 将logo画到上下文中
    [logo drawInRect:logoRect];
    
    // 从上下文中读取image
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return codeImage;
}



#pragma mark - 打开/关闭手电筒

- (void)observeLightStatus:(void (^)(BOOL, BOOL))lightStatus {
    
    _lightStatus = lightStatus;
    
    AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
    [lightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if ([_session canAddOutput:lightOutput]) {
        [_session addOutput:lightOutput];
    }
}

+ (void)switchTorch:(BOOL)on {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureTorchMode torchMode = on? AVCaptureTorchModeOn: AVCaptureTorchModeOff;
    
    if (device.hasFlash && device.hasTorch && torchMode != device.torchMode) {
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDicRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadataDic = (__bridge NSDictionary *)metadataDicRef;
    CFRelease(metadataDicRef);
    NSDictionary *exifDic = metadataDic[(__bridge NSString *)kCGImagePropertyExifDictionary];
    CGFloat brightness = [exifDic[(__bridge NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL torchOn = device.torchMode == AVCaptureTorchModeOn;
    BOOL dimmed = brightness < 1.0;
    static BOOL lastDimmed = NO;
    
    if (_lightStatus) {
        if (!_lightStatusHasCalled) {
            _lightStatus(dimmed, torchOn);
            _lightStatusHasCalled = YES;
            lastDimmed = dimmed;
        }
        else if (dimmed != lastDimmed) {
            _lightStatus(dimmed, torchOn);
            lastDimmed = dimmed;
        }
    }
}



#pragma mark - 缩放手势

- (void)pin:(UIPinchGestureRecognizer *)pinGesture {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    CGFloat minZoomFactor = 1.0;
    CGFloat maxZoomFactor = device.activeFormat.videoMaxZoomFactor;
    
    if (@available(iOS 11.0, *)) {
        minZoomFactor = device.minAvailableVideoZoomFactor;
        maxZoomFactor = device.maxAvailableVideoZoomFactor;
    }
    
    static CGFloat lastZoomFactor = 1.0;
    if (pinGesture.state == UIGestureRecognizerStateBegan) {
        lastZoomFactor = device.videoZoomFactor;
    }
    else if (pinGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat zoomFactor = lastZoomFactor * pinGesture.scale;
        zoomFactor = fmaxf(fminf(zoomFactor, maxZoomFactor), minZoomFactor);
        [device lockForConfiguration:nil];
        device.videoZoomFactor = zoomFactor;
        [device unlockForConfiguration];
    }
}


#pragma mark - Private functions

+ (void)resetZoomFactor {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    device.videoZoomFactor = 1.0;
    [device unlockForConfiguration];
}

@end

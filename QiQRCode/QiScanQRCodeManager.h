//
//  QiScanQRCodeManager.h
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QiScanQRCodeManager : NSObject

@property (nonatomic, strong) AVCaptureSession *session;

- (instancetype)initWithPreviewView:(UIView *)previewView rectFrame:(CGRect)rectFrame;

- (void)startScanningWithCallback:(void(^)(NSString *))callback autoStop:(BOOL)autoStop;
- (void)startScanningWithCallback:(void(^)(NSString *))callback;
- (void)stopScanning;

@end

NS_ASSUME_NONNULL_END

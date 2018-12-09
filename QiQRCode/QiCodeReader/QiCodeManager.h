//
//  QiCodeManager.h
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiCodePreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QiCodeManager : NSObject

#pragma mark - 扫描二维码/条形码

- (instancetype)initWithPreviewView:(QiCodePreviewView *)previewView completion:(void(^)(void))completion;

- (void)startScanningWithCallback:(void(^)(NSString *))callback autoStop:(BOOL)autoStop;
- (void)startScanningWithCallback:(void(^)(NSString *))callback;
- (void)stopScanning;

- (void)presentPhotoLibraryWithRooter:(UIViewController *)rooter callback:(void(^)(NSString *))callback;


#pragma mark - 生成二维码/条形码

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo;
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

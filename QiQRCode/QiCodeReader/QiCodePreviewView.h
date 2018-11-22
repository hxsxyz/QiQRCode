//
//  QiCodePreviewView.h
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QiCodePreviewView;
@protocol QiCodePreviewViewDelegate <NSObject>

- (void)codeScanningView:(QiCodePreviewView *)scanningView didClickedTorchSwitch:(UIButton *)switchButton;

@end

@interface QiCodePreviewView : UIView

@property (nonatomic, assign, readonly) CGRect rectFrame;
@property (nonatomic, weak) id<QiCodePreviewViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame rectColor:(UIColor *)rectColor;
- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor;
- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame;

- (void)startScanning;
- (void)stopScanning;
- (void)startIndicating;
- (void)stopIndicating;
- (void)showTorchSwitch;
- (void)hideTorchSwitch;

@end

NS_ASSUME_NONNULL_END

//
//  QiCodeScanningView.h
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QiCodeScanningView;
@protocol QiCodeScanningViewDelegate <NSObject>

- (void)codeScanningView:(QiCodeScanningView *)scanningView didClickedTorchSwitch:(UIButton *)switchButton;

@end

@interface QiCodeScanningView : UIView

@property (nonatomic, assign, readonly) CGRect rectFrame;
@property (nonatomic, weak) id<QiCodeScanningViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame rectColor:(UIColor *)rectColor;
- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor;
- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame;
- (void)startScanningAnimation:(BOOL)start;
- (void)showTorchSwithButton:(BOOL)show;

@end

NS_ASSUME_NONNULL_END

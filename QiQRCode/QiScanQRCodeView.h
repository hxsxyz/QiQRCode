//
//  QiScanQRCodeView.h
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QiScanQRCodeView : UIView

@property (nonatomic, assign, readonly) CGRect rectFrame;

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame;

- (void)startScanningAnimation;
- (void)stopScanningAnimation;

@end

NS_ASSUME_NONNULL_END

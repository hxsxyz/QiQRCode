//
//  QiScanQRCodeView.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiScanQRCodeView.h"

@interface QiScanQRCodeView ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *rectLayer;
@property (nonatomic, strong) CAShapeLayer *cornerLayer;
@property (nonatomic, strong) CAShapeLayer *lineLayer;

@end

@implementation QiScanQRCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    return [[QiScanQRCodeView alloc] initWithFrame:frame rectFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.masksToBounds = YES;
        
        if (CGRectEqualToRect(rectFrame, CGRectZero)) {
            CGFloat rectSide = fminf(self.layer.bounds.size.width, self.layer.bounds.size.height) * 2 / 3;
            CGFloat rectX = (self.layer.bounds.size.width - rectSide) / 2;
            CGFloat rectY = (self.layer.bounds.size.height - rectSide) / 2;
            rectFrame = (CGRect){rectX, rectY, rectSide, rectSide};
        }
        // 根据自定义的rectFrame画矩形框（扫码框）
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:(CGRect){.0, .0, rectFrame.size.width, rectFrame.size.height}];
        _rectLayer = [CAShapeLayer layer];
        _rectLayer.frame = rectFrame;
        _rectLayer.path = rectPath.CGPath;
        _rectLayer.lineWidth = .5;
        _rectLayer.strokeColor = [UIColor whiteColor].CGColor;
        _rectLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_rectLayer];
        
        // 根据rectFrame创建矩形拐角路径
        CGFloat cornerWidth = 2.0;
        CGFloat cornerLength = fminf(rectFrame.size.width, rectFrame.size.height) / 12;
        UIBezierPath *cornerPath = [UIBezierPath bezierPath];
        // 左上角
        [cornerPath moveToPoint:(CGPoint){.0, cornerWidth / 2}];
        [cornerPath addLineToPoint:(CGPoint){cornerLength, cornerWidth / 2}];
        [cornerPath moveToPoint:(CGPoint){cornerWidth / 2, .0}];
        [cornerPath addLineToPoint:(CGPoint){cornerWidth / 2, cornerLength}];
        // 右上角
        [cornerPath moveToPoint:(CGPoint){rectFrame.size.width, cornerWidth / 2}];
        [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerLength, cornerWidth / 2}];
        [cornerPath moveToPoint:(CGPoint){rectFrame.size.width - cornerWidth / 2, .0}];
        [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerWidth / 2, cornerLength}];
        // 左下角
        [cornerPath moveToPoint:(CGPoint){.0, rectFrame.size.height - cornerWidth / 2}];
        [cornerPath addLineToPoint:(CGPoint){cornerLength, rectFrame.size.height - cornerWidth / 2}];
        [cornerPath moveToPoint:(CGPoint){cornerWidth / 2, rectFrame.size.height}];
        [cornerPath addLineToPoint:(CGPoint){cornerWidth / 2, rectFrame.size.height - cornerLength}];
        // 右下角
        [cornerPath moveToPoint:(CGPoint){rectFrame.size.width, rectFrame.size.height - cornerWidth / 2}];
        [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerLength, rectFrame.size.height - cornerWidth / 2}];
        [cornerPath moveToPoint:(CGPoint){rectFrame.size.width - cornerWidth / 2, rectFrame.size.height}];
        [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerWidth / 2, rectFrame.size.height - cornerLength}];
        
        // 根据矩形拐角路径画矩形拐角
        _cornerLayer = [CAShapeLayer layer];
        _cornerLayer.frame = rectFrame;
        _cornerLayer.path = cornerPath.CGPath;
        _cornerLayer.lineWidth = cornerWidth;
        _cornerLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_cornerLayer];
        
        // 根据rectFrame画扫描线
        CGRect lineFrame = (CGRect){rectFrame.origin.x + 2.0, rectFrame.origin.y, rectFrame.size.width - 4.0, 2.0};
        UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:(CGRect){.0, .0, lineFrame.size.width, lineFrame.size.height}];
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.frame = lineFrame;
        _lineLayer.path = linePath.CGPath;
        _lineLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:.8].CGColor;
        _lineLayer.shadowColor = [UIColor whiteColor].CGColor;
        _lineLayer.shadowRadius = lineFrame.size.height;
        _lineLayer.shadowOffset = (CGSize){.0, .0};
        _lineLayer.shadowOpacity = 1.0;
        
        // 根据rectFrame求最大边距
        CGFloat rectTop = rectFrame.origin.y;
        CGFloat rectLeft = rectFrame.origin.x;
        CGFloat rectRight = self.layer.bounds.size.width - rectFrame.size.width - rectLeft;
        CGFloat rectBottom = self.layer.bounds.size.height - rectFrame.size.height - rectTop;
        CGFloat rectMaxMargin = fmaxf(rectTop, fmaxf(rectLeft, fmaxf(rectRight, rectBottom)));
        
        // 根据最大边距求遮罩的frame
        CGFloat maskTop = rectTop - rectMaxMargin;
        CGFloat maskLeft = rectLeft - rectMaxMargin;
        CGFloat maskRight = rectRight - rectMaxMargin;
        CGFloat maskBottom = rectBottom - rectMaxMargin;
        CGFloat maskWidth = self.layer.bounds.size.width + fabs(maskLeft) + fabs(maskRight);
        CGFloat maskHeight = self.layer.bounds.size.height + fabs(maskTop) + fabs(maskBottom);
        
        // 根据遮罩的frame求贝塞尔曲线
        CGFloat pathTop = maskTop + rectMaxMargin / 2;
        CGFloat pathLeft = maskLeft + rectMaxMargin / 2;
        CGFloat pathWidth = maskWidth - rectMaxMargin;
        CGFloat pathHeight = maskHeight - rectMaxMargin;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:(CGRect){pathLeft, pathTop, pathWidth, pathHeight}];
        
        // 根据贝塞尔曲线画图
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.path = maskPath.CGPath;
        _maskLayer.lineWidth = rectMaxMargin;
        _maskLayer.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer insertSublayer:_maskLayer atIndex:0];
    }
    
    return self;
}


#pragma mark - Public functions

- (CGRect)rectFrame {
    
    return _rectLayer.frame;
}

- (void)startScanningAnimation {
    
    [self stopScanningAnimation];
    
    if (!_lineLayer.superlayer) {
        [self.layer insertSublayer:_lineLayer above:_cornerLayer];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, _rectLayer.frame.origin.y + _lineLayer.frame.size.height}];
    animation.toValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, _rectLayer.frame.origin.y + _rectLayer.frame.size.height - _lineLayer.frame.size.height}];
    animation.duration = 2.0;
    animation.autoreverses = YES;
    animation.repeatCount = CGFLOAT_MAX;
    [_lineLayer addAnimation:animation forKey:@"lineLayerAnimation"];
}

- (void)stopScanningAnimation {
    
    [_lineLayer removeAllAnimations];
    [_lineLayer removeFromSuperlayer];
}

@end

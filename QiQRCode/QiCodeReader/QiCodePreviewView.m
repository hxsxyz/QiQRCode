//
//  QiCodePreviewView.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiCodePreviewView.h"

@interface QiCodePreviewView ()

@property (nonatomic, strong) CAShapeLayer *cornerLayer;
@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CABasicAnimation *lineAnimation;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *torchSwithButton;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation QiCodePreviewView{
    CGRect _rectFrame;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    return [[QiCodePreviewView alloc] initWithFrame:frame rectFrame:CGRectZero rectColor:[UIColor clearColor]];
}

- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor {
    
    return [[QiCodePreviewView alloc] initWithFrame:frame rectFrame:CGRectZero rectColor:rectColor];
}

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame {
    
    return [[QiCodePreviewView alloc] initWithFrame:frame rectFrame:rectFrame rectColor:[UIColor clearColor]];
}

- (instancetype)initWithFrame:(CGRect)frame rectFrame:(CGRect)rectFrame rectColor:(UIColor *)rectColor {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;
        
        if (CGRectEqualToRect(rectFrame, CGRectZero)) {
            CGFloat rectSide = fminf(self.layer.bounds.size.width, self.layer.bounds.size.height) * 2 / 3;
            rectFrame = CGRectMake((self.layer.bounds.size.width - rectSide) / 2, (self.layer.bounds.size.height - rectSide) / 2, rectSide, rectSide);
        }
        if (CGColorEqualToColor(rectColor.CGColor, [UIColor clearColor].CGColor)) {
            rectColor = [UIColor whiteColor];
        }
        
        _rectFrame = rectFrame;
        // 遮罩
        UIView *coverView = [[UIView alloc] init];
        coverView.frame = self.bounds;
        coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self addSubview:coverView];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:coverView.bounds];
        UIBezierPath *rectPath = [[UIBezierPath bezierPathWithRect:rectFrame] bezierPathByReversingPath];
        [path appendPath:rectPath];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        coverView.layer.mask = shapeLayer;
        
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
        _cornerLayer.strokeColor = rectColor.CGColor;
        [self.layer addSublayer:_cornerLayer];
        
        // 根据rectFrame画扫描线
        CGRect lineFrame = (CGRect){rectFrame.origin.x + 5.0, rectFrame.origin.y, rectFrame.size.width - 5.0 * 2, 1.5};
        UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:(CGRect){.0, .0, lineFrame.size.width, lineFrame.size.height}];
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.frame = lineFrame;
        _lineLayer.path = linePath.CGPath;
        _lineLayer.fillColor = rectColor.CGColor;
        _lineLayer.shadowColor = rectColor.CGColor;
        _lineLayer.shadowRadius = 5.0;
        _lineLayer.shadowOffset = CGSizeMake(.0, .0);
        _lineLayer.shadowOpacity = 1.0;
        _lineLayer.hidden = YES;
        [self.layer addSublayer:_lineLayer];
        
        // 扫描线动画
        _lineAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        _lineAnimation.fromValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, _rectFrame.origin.y + _lineLayer.frame.size.height}];
        _lineAnimation.toValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, _rectFrame.origin.y + _rectFrame.size.height - _lineLayer.frame.size.height}];
        _lineAnimation.repeatCount = CGFLOAT_MAX;
        _lineAnimation.autoreverses = YES;
        _lineAnimation.duration = 2.0;
        
        // 手电筒开关
        _torchSwithButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _torchSwithButton.frame = CGRectMake(.0, .0, 60.0, 70.0);
        _torchSwithButton.center = CGPointMake(CGRectGetMidX(rectFrame), CGRectGetMaxY(rectFrame) - CGRectGetMidY(_torchSwithButton.bounds));
        _torchSwithButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_torchSwithButton setTitle:@"轻触照亮" forState:UIControlStateNormal];
        [_torchSwithButton setTitle:@"轻触关闭" forState:UIControlStateSelected];
        [_torchSwithButton setImage:[UIImage imageNamed:@"qi_torch_switch_off"] forState:UIControlStateNormal];
        [_torchSwithButton setImage:[[UIImage imageNamed:@"qi_torch_switch_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_torchSwithButton addTarget:self action:@selector(torchSwitchClicked:) forControlEvents:UIControlEventTouchUpInside];
        _torchSwithButton.tintColor = rectColor;
        _torchSwithButton.titleEdgeInsets = UIEdgeInsetsMake(_torchSwithButton.imageView.frame.size.height + 5.0, -_torchSwithButton.imageView.bounds.size.width, .0, .0);
        _torchSwithButton.imageEdgeInsets = UIEdgeInsetsMake(.0, _torchSwithButton.titleLabel.bounds.size.width / 2, _torchSwithButton.titleLabel.frame.size.height + 5.0, - _torchSwithButton.titleLabel.bounds.size.width / 2);
        _torchSwithButton.hidden = YES;
        [self addSubview:_torchSwithButton];
        
        // 提示语label
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:13.0];
        _tipsLabel.text = @"将二维码/条形码放入框内即可自动扫描";
        _tipsLabel.numberOfLines = 0;
        [_tipsLabel sizeToFit];
        _tipsLabel.center = CGPointMake(CGRectGetMidX(rectFrame), CGRectGetMaxY(rectFrame) + CGRectGetMidY(_tipsLabel.bounds)+ 12.0);
        [self addSubview:_tipsLabel];
        
        // 等待指示view
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:rectFrame];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
}


#pragma mark - Public functions

- (CGRect)rectFrame {
    
    return _rectFrame;
}

- (void)startScanning {
    
    _lineLayer.hidden = NO;
    [_lineLayer addAnimation:_lineAnimation forKey:@"lineAnimation"];
}

- (void)stopScanning {
    
    _lineLayer.hidden = YES;
    [_lineLayer removeAnimationForKey:@"lineAnimation"];
}

- (void)startIndicating {
    
    [_indicatorView stopAnimating];
}

- (void)stopIndicating {
    
    [_indicatorView stopAnimating];
}

- (void)showTorchSwitch {
    
    _torchSwithButton.hidden = NO;
    _torchSwithButton.alpha = .0;
    [UIView animateWithDuration:.25 animations:^{
        self.torchSwithButton.alpha = 1.0;
    }];
}

- (void)hideTorchSwitch {
    
    [UIView animateWithDuration:.1 animations:^{
        self.torchSwithButton.alpha = .0;
    } completion:^(BOOL finished) {
        self.torchSwithButton.hidden = YES;
    }];
}


#pragma mark - Private functions

- (void)didAddSubview:(UIView *)subview {
    
    if (subview == _indicatorView) {
        [_indicatorView startAnimating];
    }
}


#pragma mark - Action functions

- (void)torchSwitchClicked:(UIButton *)button {
    
    if ([_delegate respondsToSelector:@selector(codeScanningView:didClickedTorchSwitch:)]) {
        [_delegate codeScanningView:self didClickedTorchSwitch:button];
    }
}

@end

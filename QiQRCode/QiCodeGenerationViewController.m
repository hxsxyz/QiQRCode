//
//  QiCodeGenerationViewController.m
//  QiQRCode
//
//  Created by huangxianshuai on 2018/11/13.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiCodeGenerationViewController.h"
#import "QiCodeManager.h"

@interface QiCodeGenerationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;

@end

@implementation QiCodeGenerationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _codeLabel.text = _code;
}


#pragma mark - Action functions

- (IBAction)generateQRCode:(id)sender {
 
    UIImage *codeImage = [QiCodeManager generateQRCode:_code size:_codeImageView.bounds.size logo:[UIImage imageNamed:@"qi_logo_qrcode"]];
    _codeImageView.image = codeImage;
}

- (IBAction)generateCode128:(id)sender {
    
    UIImage *codeImage = [QiCodeManager generateCode128:_code size:_codeImageView.bounds.size];
    _codeImageView.image = codeImage;
}

- (IBAction)codeLabelTapped:(id)sender {
    
    NSURL *codeURL = [NSURL URLWithString:_codeLabel.text];
    
    if ([[UIApplication sharedApplication] canOpenURL:codeURL]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"将跳转至Safari打开此链接" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:codeURL];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confimAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"将跳转至Safari打开此链接" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:codeURL];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confimAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

@end

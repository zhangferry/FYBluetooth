//
//  ViewController.m
//  FYBluetooth
//
//  Created by zhangfei on 15/12/31.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothHeader.h"

@interface ViewController ()<FYBluetoothDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic)BluetoothHeader *header;
@property (copy, nonatomic) NSString *identifider;
@property (strong, nonatomic) NSMutableString *string;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.header = [BluetoothHeader sharedInstance];
    [self.header initDevice];
    
    self.string = [NSMutableString string];
}

//防止返回时代理覆盖，要重新挂代理
- (void)viewWillAppear:(BOOL)animated{
    
    self.header.delegate = self;
    
}

- (IBAction)scan:(id)sender {
    [_header scan];
}

- (IBAction)connect:(id)sender {
    [_header connect:self.identifider];
}
- (IBAction)disConnect:(id)sender {
    [_header disconnect];
    [_header connect:nil];
}

- (IBAction)getVersion:(id)sender {
    [_header getVersion];
}


#pragma mark - 蓝牙状态协议
//开始扫描
- (void) onScanStart{
    [_string appendString:@"开始扫描\n"];
    _textView.text = _string;
}

//停止扫描
- (void) onScanStop{
    [_string appendString:@"停止扫描\n"];
    _textView.text = _string;
}

//未找到设备
- (void) onScanNotFound{
    [_string appendString:@"未找到设备\n"];
    _textView.text = _string;
}

//连接成功
- (void) onConnected{
    NSLog(@"连接成功");
    [_string appendString:@"连接成功\n"];
    _textView.text = _string;
}

//连接失败
- (void) onConnectFailed{
    [_string appendString:@"连接失败\n"];
    _textView.text = _string;
}

//连接断开
- (void) onConnectBreak{
    [_string appendString:@"连接断开\n"];
    _textView.text = _string;
}

//获取设备标示
- (void)deviceIdentifier:(NSString *)identifier{
    self.identifider = identifier;
    [self.string appendFormat:@"发现设备：%@\n",self.identifider];
    self.textView.text = self.string;
}

//获取硬件版本
- (void)onGetVersion:(NSString *)version{
    [self.string appendFormat:@"硬件版本：%@\n",version];
    self.textView.text = self.string;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

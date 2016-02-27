//
//  BatteryViewController.m
//  FYBluetooth
//
//  Created by zhangferry on 16/2/27.
//  Copyright © 2016年 zhangferry. All rights reserved.
//

#import "BatteryViewController.h"
#import "BluetoothHeader.h"

@interface BatteryViewController ()<FYBluetoothDelegate>

@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (strong, nonatomic) BluetoothHeader *header;

@end

@implementation BatteryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.header = [BluetoothHeader sharedInstance];
    self.header.delegate = self;
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)getBattery:(id)sender {
    
    [self.header getBattery];
    
}

- (void)onGetBattery:(int)battery{
    
    self.batteryLabel.text = [NSString stringWithFormat:@"%d%%",battery];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  BluetoothHeader.h
//  FYBluetooth
//
//  Created by zhangfei on 15/12/31.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define ST_SERVICE_UUID @"D100"
#define ST_CHARACTERISTIC_UUID_WRITE_AND_NOTIFY @"8D00"
#define ST_CHARACTERISTIC_UUID_READ @"8A00"

@protocol FYBluetoothDelegate <NSObject>

//开始扫描
- (void) onScanStart;

//停止扫描
- (void) onScanStop;

//未找到设备
- (void) onScanNotFound;

//连接失败
- (void) onConnectFailed;

//连接成功
- (void) onConnected;

//连接断开
- (void) onConnectBreak;

//获取设备标示
- (void)deviceIdentifier:(NSString *)identifier;

@end


@interface BluetoothHeader : NSObject

@property (nonatomic, strong)id<FYBluetoothDelegate>delegate;

@property (nonatomic, strong)CBPeripheral *peripheral;
@property (nonatomic, strong)CBCharacteristic *write;
@property (nonatomic, strong) CBCharacteristic *read;

+ sharedInstance;
//初始化
- (void)initDevice;

//开始扫描
- (void) scan;

//开始连接，传入：address：设备(UUID)
- (void) connect:(NSString *)identify;

//断开连接
- (void) disconnect;

//获取设备版本号
- (void) getVersion;


@end

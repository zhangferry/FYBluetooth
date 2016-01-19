//
//  BluetoothHeader.m
//  FYBluetooth
//
//  Created by zhangfei on 15/12/31.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import "BluetoothHeader.h"

@interface BluetoothHeader ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) NSString *identify;

@property (nonatomic, strong) NSTimer *timer;//连接超时

@end

@implementation BluetoothHeader{
    BOOL isOpenBLE;//是否开启了蓝牙
    int countDown;//倒计时
}

+ (BluetoothHeader *)sharedInstance {
    static BluetoothHeader *deviceManage;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        deviceManage = [[BluetoothHeader alloc]init];
    });
    return deviceManage;
}

- (void)initDevice{
    NSLog(@"initDevice");
    countDown = 0;
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
}

//扫描设备
- (void)scan {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    NSLog(@"scanDevice");
    
    if (!self.timer) {
        countDown = 8;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(connectOverrun) userInfo:nil repeats:YES];
    }
}

/**
 *  停止扫描
 */
- (void)stopScan{
    
    [self.centralManager stopScan];
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"停止扫描");
}

//连接设备:
- (void)connect:(NSString *)identify {
    if (isOpenBLE) {
        self.identify = identify;
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        if (!self.timer) {
            countDown = 8;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(connectOverrun) userInfo:nil repeats:YES];
        }
    }
}

//断开设备连接:
- (void)disconnect {
    if(self.centralManager && self.peripheral){
        NSLog(@"disConnectDevice");
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        if ([self.delegate respondsToSelector:@selector(onConnectBreak)]) {
            [self.delegate onConnectBreak];
        }
    }
}
/**
 *  连接超时
 */
- (void)connectOverrun {
    countDown -= 1;
    if (countDown == 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.centralManager stopScan];
        if ([self.delegate respondsToSelector:@selector(onScanNotFound)]) {
            [self.delegate onScanNotFound];
        }
    }
}

/**
 *  更新蓝牙状态
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        isOpenBLE = YES;
        NSLog(@"bluetoothopen");
        
    } else if(central.state == CBCentralManagerStatePoweredOff){
        NSLog(@"bluetoothclose");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectState" object:@"蓝牙关闭!"];
        
    }else {
        NSLog(@"蓝牙未打开!");
    }
    
}

//获取设备版本号
- (void) getVersion {
    NSData *data = [self hexToBytes:@"088573"];
    [self.peripheral writeValue:data forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
}


#pragma mark - CBCentralManagerDelegate方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%@", [peripheral.identifier UUIDString]);
    //筛选设备名
    if([peripheral.name rangeOfString:@"MI"].location != NSNotFound){
        NSLog(@"didDiscoverPeripheral");
        
        if (self.identify) {
            if ([[peripheral.identifier UUIDString] isEqualToString:self.identify]) {
                [self.centralManager connectPeripheral:peripheral options:nil];
                NSLog(@"成功连接设备");
                
                self.peripheral = peripheral;
                [self.timer invalidate];
                self.timer = nil;
            }
        } else {
            NSUUID *uuid = peripheral.identifier;
            NSLog(@"%@",peripheral.name);
            if ([self.delegate respondsToSelector:@selector(deviceIdentifier:)]) {
                [self.delegate deviceIdentifier:[uuid UUIDString]];
            }
            
            [self.centralManager stopScan];
            if ([self.delegate respondsToSelector:@selector(onScanStop)]) {
                [self.delegate onScanStop];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed to connnet peripheral %@ (%@)", peripheral, error);
    if ([self.delegate respondsToSelector:@selector(onConnectFailed)]) {
        [self.delegate onConnectFailed];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(onConnectBreak)]) {
        [self.delegate onConnectBreak];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
    if ([self.delegate respondsToSelector:@selector(onConnected)]) {
        [self.delegate onConnected];
    }
    [self.centralManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}
#pragma mark - Peripheral delegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"serviceUUID:%@", service.UUID.UUIDString);
            if ([service.UUID.UUIDString isEqualToString:ST_SERVICE_UUID]) {
                [self.peripheral discoverCharacteristics:service.characteristics
                                              forService:service];
            }
        }
    }
}
/**
 *  //发现characteristics，由发现服务调用（上一步），获取读和写的characteristics
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:ST_CHARACTERISTIC_UUID_READ]) {
            self.read = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.read];
        } else if ([characteristic.UUID.UUIDString isEqualToString:ST_CHARACTERISTIC_UUID_WRITE_AND_NOTIFY]) {
            self.write = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Failed to subscribe to peripheral %@ (%@)", peripheral, error);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
}
//是否写入成功的代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
}
//数据接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if ([characteristic.UUID.UUIDString isEqualToString:ST_CHARACTERISTIC_UUID_READ]) {
        NSData *data = characteristic.value;
        NSLog(@"设备返回码：%@",data);
        
        //根据硬件协议进行解析
        
    }
}

//字符串转data
- (NSData*)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

@end

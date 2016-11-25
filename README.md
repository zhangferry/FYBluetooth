# FYBluetooth

基于CoreBluetooth4.0框架连接BLE4.0的Demo,具有一下功能：

* 扫描
* 连接
* 断开
* 查看版本号功能。

扫描已连接设备：

    /*!
    *  @method retrievePeripheralsWithIdentifiers:
    *
    *  @param identifiers	NSUUID数组
    *
    *	@return				返回CBPeripheral数组
    */
    - (NSArray<CBPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers NS_AVAILABLE(NA, 7_0);

    /*!
    *  @method retrieveConnectedPeripheralsWithServices
    *
    *  @discussion 通过serviceUUIDs检索所有连接到系统的外围设备
    *				Note 包括被其他应用连接的设备
    *
    *	@return		返回CBPeripheral数组
    */
    - (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs NS_AVAILABLE(NA, 7_0);

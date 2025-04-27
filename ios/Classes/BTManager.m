// BTManager.m
#import "BTManager.h"
#import "JL_BLEMultiple.h"

@interface BTManager ()
@property (nonatomic, assign) BTConnectionStatus connectionStatus;
@property (nonatomic, strong) NSTimer *reconnectTimer;
@end

@implementation BTManager

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static BTManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // Initialize BLE Multiple
    self.mBleMultiple = [[JL_BLEMultiple alloc] init];
    
    // Set default values
    self.connectionStatus = BTConnectionStatusDisconnected;
    self.autoReconnect = NO;
    
    // Set weak references to arrays
    self.mFoundArray = self.mBleMultiple.blePeripheralArr;
    self.mConnectedArray = self.mBleMultiple.bleConnectedArr;
    
    // Set up notifications for device events
    [self setupNotifications];
}

#pragma mark - Setup

- (void)setupWithFiltering:(BOOL)filteringEnabled pairingEnabled:(BOOL)pairingEnabled timeout:(NSInteger)timeout {
    self.mBleMultiple.BLE_FILTER_ENABLE = filteringEnabled;
    self.mBleMultiple.BLE_PAIR_ENABLE = pairingEnabled;
    self.mBleMultiple.BLE_TIMEOUT = timeout;
}

- (void)setDeviceTypesToScan:(NSArray *)deviceTypes {
    self.mBleMultiple.bleDeviceTypeArr = deviceTypes;
}

- (void)setupNotifications {
    // Register for notifications from the SDK
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleDeviceDiscovered:) 
                                                 name:@"JL_DEVICE_DISCOVERED_NOTIFICATION" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleDeviceConnected:) 
                                                 name:@"JL_DEVICE_CONNECTED_NOTIFICATION" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleDeviceDisconnected:) 
                                                 name:@"JL_DEVICE_DISCONNECTED_NOTIFICATION" 
                                               object:nil];
    
    // Note: You may need to adjust notification names based on actual SDK implementation
}

#pragma mark - Scanning

- (void)startScan {
    [self.mBleMultiple scanStart];
    
    // Update references after scan starts
    self.mFoundArray = self.mBleMultiple.blePeripheralArr;
    self.mConnectedArray = self.mBleMultiple.bleConnectedArr;
}

- (void)stopScan {
    [self.mBleMultiple scanStop];
}

#pragma mark - Connection Management

- (void)connectToDevice:(JL_EntityM *)device {
    if (!device) {
        NSLog(@"Error: Attempted to connect to nil device");
        return;
    }
    
    self.connectionStatus = BTConnectionStatusConnecting;
    
    if ([self.delegate respondsToSelector:@selector(btManagerConnectionStatusChanged:)]) {
        [self.delegate btManagerConnectionStatusChanged:self.connectionStatus];
    }
    
    // Store UUID for reconnection purposes
    self.mBleUUID = device.peripheralM.identifier.UUIDString;
    
    // Connect using the SDK
    [self.mBleMultiple connectPeripheral:device.peripheralM];
}

- (void)disconnectCurrentDevice {
    if (self.mBleEntityM) {
        [self.mBleMultiple disconnectPeripheral:self.mBleEntityM.peripheralM];
        self.mBleEntityM = nil;
        self.connectionStatus = BTConnectionStatusDisconnected;
        
        if ([self.delegate respondsToSelector:@selector(btManagerConnectionStatusChanged:)]) {
            [self.delegate btManagerConnectionStatusChanged:self.connectionStatus];
        }
    }
}

- (void)disconnectAllDevices {
    // Disconnect all connected devices
    for (JL_EntityM *device in self.mConnectedArray) {
        [self.mBleMultiple disconnectPeripheral:device.peripheralM];
    }
    
    self.mBleEntityM = nil;
    self.connectionStatus = BTConnectionStatusDisconnected;
    
    if ([self.delegate respondsToSelector:@selector(btManagerConnectionStatusChanged:)]) {
        [self.delegate btManagerConnectionStatusChanged:self.connectionStatus];
    }
}

- (JL_EntityM *)deviceWithUUID:(NSString *)uuid {
    // Check connected devices
    for (JL_EntityM *device in self.mConnectedArray) {
        if ([device.peripheralM.identifier.UUIDString isEqualToString:uuid]) {
            return device;
        }
    }
    
    // Check discovered devices
    for (JL_EntityM *device in self.mFoundArray) {
        if ([device.peripheralM.identifier.UUIDString isEqualToString:uuid]) {
            return device;
        }
    }
    
    return nil;
}

- (BOOL)isDeviceConnected:(JL_EntityM *)device {
    if (!device) return NO;
    
    for (JL_EntityM *connectedDevice in self.mConnectedArray) {
        if ([connectedDevice.peripheralM.identifier.UUIDString 
             isEqualToString:device.peripheralM.identifier.UUIDString]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Auto Reconnect

- (void)startReconnectTimer {
    [self stopReconnectTimer];
    
    if (self.autoReconnect && self.mBleUUID) {
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                               target:self
                                                             selector:@selector(attemptReconnect)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

- (void)stopReconnectTimer {
    if (self.reconnectTimer && [self.reconnectTimer isValid]) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
}

- (void)attemptReconnect {
    if (self.connectionStatus == BTConnectionStatusConnected) {
        [self stopReconnectTimer];
        return;
    }
    
    // Try to find the device
    JL_EntityM *device = [self deviceWithUUID:self.mBleUUID];
    if (device) {
        [self connectToDevice:device];
    } else {
        // If device not found, try to restart scanning
        [self startScan];
    }
}

#pragma mark - Notification Handlers

- (void)handleDeviceDiscovered:(NSNotification *)notification {
    // Update references
    self.mFoundArray = self.mBleMultiple.blePeripheralArr;
    
    if ([self.delegate respondsToSelector:@selector(btManagerDidDiscoverDevices:)]) {
        [self.delegate btManagerDidDiscoverDevices:self.mFoundArray];
    }
    
    // If auto-reconnect is enabled and we have a UUID, check if our device is found
    if (self.autoReconnect && self.mBleUUID && self.connectionStatus == BTConnectionStatusDisconnected) {
        JL_EntityM *device = [self deviceWithUUID:self.mBleUUID];
        if (device) {
            [self connectToDevice:device];
        }
    }
}

- (void)handleDeviceConnected:(NSNotification *)notification {
    // Get the connected device from notification
    JL_EntityM *device = notification.object;
    
    // Update references
    self.mConnectedArray = self.mBleMultiple.bleConnectedArr;
    
    // Set as current device
    self.mBleEntityM = device;
    self.connectionStatus = BTConnectionStatusConnected;
    
    // Stop reconnect timer if running
    [self stopReconnectTimer];
    
    if ([self.delegate respondsToSelector:@selector(btManagerDidConnectDevice:)]) {
        [self.delegate btManagerDidConnectDevice:device];
    }
    
    if ([self.delegate respondsToSelector:@selector(btManagerConnectionStatusChanged:)]) {
        [self.delegate btManagerConnectionStatusChanged:self.connectionStatus];
    }
}

- (void)handleDeviceDisconnected:(NSNotification *)notification {
    // Get the disconnected device from notification
    JL_EntityM *device = notification.object;
    
    // Update references
    self.mConnectedArray = self.mBleMultiple.bleConnectedArr;
    self.mFoundArray = self.mBleMultiple.blePeripheralArr;
    
    // Clear current device if it's the one that disconnected
    if (self.mBleEntityM == device) {
        self.mBleEntityM = nil;
    }
    
    self.connectionStatus = BTConnectionStatusDisconnected;
    
    if ([self.delegate respondsToSelector:@selector(btManagerDidDisconnectDevice:)]) {
        [self.delegate btManagerDidDisconnectDevice:device];
    }
    
    if ([self.delegate respondsToSelector:@selector(btManagerConnectionStatusChanged:)]) {
        [self.delegate btManagerConnectionStatusChanged:self.connectionStatus];
    }
    
    // Start reconnect timer if auto-reconnect is enabled
    if (self.autoReconnect) {
        [self startReconnectTimer];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopReconnectTimer];
}

@end


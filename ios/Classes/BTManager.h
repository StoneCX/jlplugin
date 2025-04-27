// BTManager.h
#import <Foundation/Foundation.h>
#import "JL_BLEMultiple.h"
#import "JL_EntityM.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BTConnectionStatus) {
    BTConnectionStatusDisconnected,
    BTConnectionStatusConnecting,
    BTConnectionStatusConnected,
    BTConnectionStatusFailed
};

@protocol BTManagerDelegate <NSObject>
@optional
- (void)btManagerDidDiscoverDevices:(NSArray *)devices;
- (void)btManagerDidConnectDevice:(JL_EntityM *)device;
- (void)btManagerDidDisconnectDevice:(JL_EntityM *)device;
- (void)btManagerConnectionDidFail:(NSError *)error;
- (void)btManagerConnectionStatusChanged:(BTConnectionStatus)status;
@end

@interface BTManager : NSObject

// Singleton instance
+ (instancetype)sharedInstance;

// Properties from your sample
@property (strong, nonatomic) JL_BLEMultiple *mBleMultiple;
@property (weak, nonatomic) JL_EntityM *mBleEntityM;     // Current operating device (weak reference)
@property (strong, nonatomic) NSString *mBleUUID;
@property (weak, nonatomic) NSArray *mFoundArray;        // Scanned devices (weak reference)
@property (weak, nonatomic) NSArray *mConnectedArray;    // Connected devices (weak reference)

// Additional useful properties
@property (nonatomic, weak) id<BTManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BTConnectionStatus connectionStatus;
@property (nonatomic, assign) BOOL autoReconnect;

// Methods
- (void)setupWithFiltering:(BOOL)filteringEnabled pairingEnabled:(BOOL)pairingEnabled timeout:(NSInteger)timeout;
- (void)setDeviceTypesToScan:(NSArray *)deviceTypes;
- (void)startScan;
- (void)stopScan;
- (void)connectToDevice:(JL_EntityM *)device;
- (void)disconnectCurrentDevice;
- (void)disconnectAllDevices;
- (JL_EntityM *)deviceWithUUID:(NSString *)uuid;
- (BOOL)isDeviceConnected:(JL_EntityM *)device;

@end

NS_ASSUME_NONNULL_END



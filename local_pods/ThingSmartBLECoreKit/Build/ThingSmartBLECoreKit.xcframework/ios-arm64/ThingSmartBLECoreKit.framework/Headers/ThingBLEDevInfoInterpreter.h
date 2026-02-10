//
//  ThingBLEDevInfoInterpreter.h
//  ThingSmartBLEKit
//
//

#import <Foundation/Foundation.h>
#import "ThingBLEDevInfo.h"

typedef enum : NSUInteger {
    ThingBLEAdvEncryptAuthkey              = 0,
    ThingBLEAdvEncryptECC                  = 1,
    ThingBLEAdvEncryptPassthrough          = 2,
    ThingBLEAdvEncryptCompress             = 3, 
    ThingBLEAdvEncryptAdvance              = 4, 
    ThingBLEAdvEncryptQRCode               = 5, 
    ThingBLEAdvEncryptAuthkeyWithMac       = 6,
    ThingBLEAdvEncryptAdvanceWithMac       = 7, 
    ThingBLEAdvEncryptQRCodeWithMac        = 8,
} ThingBLEAdvEncryptMode;

typedef enum : NSUInteger {
    ThingBLEAdvProductId            = 00,
    ThingBLEAdvProductKey           = 01,
} ThingBLEAdvProductType;


@interface FrameControlModel : NSObject

//@property (nonatomic, assign) BOOL               timestampInclude; 
//@property (nonatomic, assign) BOOL               dpDataEncrypted;   
@property (nonatomic, assign) BOOL gatewayConnectModel;
@property (nonatomic, assign) NSUInteger connectivity;

@property (nonatomic, assign) BOOL               dpDataInclude;    
@property (nonatomic, assign) BOOL               idInclude;        
@property (nonatomic, assign) BOOL               requestConnection;
@property (nonatomic, assign) BOOL               sharedFlag;      
@property (nonatomic, assign) BOOL               boundFlag;       
@property (nonatomic, strong) NSString           *version;          
@property (nonatomic, assign) BOOL isExecutedV2Secret;  //execute secret
@property (nonatomic, assign) BOOL isSupportV2Secret;  //support secret

@end

@interface FrameControlModelExt : NSObject
////// Whether the device is support  roam
@property (nonatomic, assign) BOOL              isRoaming;


@end


@interface ThingBLEDevInfoInterpreter : NSObject


+ (ThingBLEAdvModel *)getBLEDeviceBroadcastInfo:(ThingBLEPeripheral *)p;


+ (ThingBLEDevInfo *)getBaseDevInfo:(NSString *)hexStr withUUID:(NSString *)uuid;


+ (ThingBLEDevInfo *)getPlusDevInfo:(NSString *)hexStr withUUID:(NSString *)uuid;


+ (ThingBLESecurityDevInfo *)getSecurityDevInfo:(NSString *)hexStr;


/**
 *ThingBLEDevInfoInterpreter
 */
+ (ThingBLEPlugPlayDevInfo *)getPlugPlayDeviceInfo:(NSString *)hexStr;


+ (BOOL)deviceSupportMultiUser:(ThingBLEPeripheral *)p;

+ (FrameControlModel *)frameControlResolution:(NSString *)data;

@end

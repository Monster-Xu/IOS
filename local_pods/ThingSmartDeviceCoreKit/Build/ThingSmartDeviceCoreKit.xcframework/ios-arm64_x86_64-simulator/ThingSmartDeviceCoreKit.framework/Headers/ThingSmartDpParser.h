//
//  ThingSmartDpParser.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartDp;
@class ThingSmartSwitchDp;

@protocol ThingSmartDpDataSourceProtocol <NSObject>
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *dps; // Mapping of dpId to current dpValue
@property (nonatomic, strong, readonly) NSArray<ThingSmartSchemaModel *> *schemaArray; //All DP schema
@property (nonatomic, assign, readonly) BOOL switchDpsValue; // Current value of switch DP
@property (nonatomic, strong, readonly) NSArray<NSNumber *> * switchDps; // A dpId list of switch DP
@property (nonatomic, strong, readonly) NSArray<NSNumber *> * displayDps;// A dpId list of display DP
@property (nonatomic, strong, readonly) NSArray<NSNumber *> * quickOpDps;// A dpId list of quick operate DP
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *dpName; // Mapping of dpId to title
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> * displayMsgs;// Mapping of dp code to show content
@property (nonatomic, strong, readonly) NSString * schemaExt; // A json string of shcema additional information
@property (nonatomic, strong, readonly) ThingSmartStandSchemaModel *standSchemaModel;
@end

/// Device or Group DP Schema Parser Tool
@interface ThingSmartDpParser : NSObject
/// Create SmartDpParser with device or group
/// - Parameter targetInfo: instance of ThingSmartDeviceModel / ThingSmartDevice / ThingSmartGroupModel / ThingSmartGroup
+ (instancetype)createWithTargetInfo:(id)targetInfo;
/// DataSource
@property (nonatomic, strong, readonly) id<ThingSmartDpDataSourceProtocol> dpDataSource;

/// Display DP of the current device (group) , quickOp property is 'NO'
@property (nonatomic, strong, readonly) NSArray<__kindof ThingSmartDp *> * displayDp;
/// Operate DP of the current device (group), quickOp property is 'YES'
@property (nonatomic, strong, readonly) NSArray<__kindof ThingSmartDp *> * operableDp;
/// Get all DP of the current device (group), quickOp property is 'NO'
@property (nonatomic, strong, readonly) NSArray<__kindof ThingSmartDp *> * allDp;
/// Switch DP of the current device (group)
@property (nonatomic, strong, nullable, readonly) ThingSmartSwitchDp * switchDp;
@property (nonatomic, strong, nullable, readonly) NSArray<NSString *> * standardDpCodes;

- (nullable __kindof ThingSmartDp *)smartDpWithDpId:(NSInteger)dpId quickOp:(BOOL)quickOp;
+ (NSArray<__kindof ThingSmartDp *> *)smartDpListWithDpDataSource:(id<ThingSmartDpDataSourceProtocol>)dpDataSource
                                                              dps:(NSArray<NSNumber *> *)dps
                                                          quickOp:(BOOL)quickOp;
@end

typedef NS_ENUM(NSInteger, ThingSmartDpType) {
    ThingSmartDpType_Bool,
    ThingSmartDpType_Enum,
    ThingSmartDpType_Num,
    ThingSmartDpType_Light,
    ThingSmartDpType_String,
};

@interface ThingSmartDpValueDisplay : NSObject
@property (nonatomic, strong, readonly) ThingSmartDp * smartDp;
@property (nonatomic, strong, readonly) id dpValue;

@property (nonatomic, strong, nullable, readonly) NSString * displayValue;
@property (nonatomic, strong, nullable, readonly) NSString * displayUnit;

- (NSString *)dpValueDisplayStr;
@end

@interface ThingSmartDp : NSObject
/// Create SmartDp with device or group
/// - Parameters:
///   - targetInfo: instance of ThingSmartDeviceModel / ThingSmartDevice / ThingSmartGroupModel / ThingSmartGroup
///   - dpId: dpId
///   - quickOp: display style
+ (nullable __kindof ThingSmartDp *)smartDpWithTargetInfo:(id)targetInfo
                                                     dpId:(NSInteger)dpId
                                                  quickOp:(BOOL)quickOp;
/// Create SmartDp list with device or group
/// - Parameters:
///   - targetInfo: instance of ThingSmartDeviceModel / ThingSmartDevice / ThingSmartGroupModel / ThingSmartGroup
///   - dps: dpId list
///   - quickOp: display style
+ (NSArray<__kindof ThingSmartDp *> *)smartDpListWithTargetInfo:(id)targetInfo
                                                            dps:(NSArray<NSNumber *> *)dps
                                                        quickOp:(BOOL)quickOp;


/// DataSource
@property (nonatomic, strong, readonly) id<ThingSmartDpDataSourceProtocol> dpDataSource;

/// SchemaModel of current DP
@property (nonatomic, strong, readonly) ThingSmartSchemaModel * schemaModel;
@property (nonatomic, assign, readonly) ThingSmartDpType smartDpType;
@property (nonatomic, strong, readonly) NSString * standardDpCode;
@property (nonatomic, strong, readonly) NSString * strategyCode;

@property (nonatomic, assign, readonly) NSInteger dpId;
@property (nonatomic, strong, readonly) NSString * dpType;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSString * iconname;
@property (nonatomic, strong, readonly) NSString * unit;

@property (nonatomic, strong, readonly) id curDpValue;

/// Get title display content under the current DP
@property (nonatomic, strong, readonly) NSString * titleStatus;

/// Get 'curDpValue' display content under the current DP
@property (nonatomic, strong, readonly) NSString * valueStatus;

- (nullable NSDictionary *)publishCommands:(id)newDpValue;

/// Get custom dpValue display content under the current DP
/// - Parameter dpValue: custom dpValue
- (NSString *)valueStatusWithDpValue:(id)dpValue;


- (ThingSmartDpValueDisplay *)valueDisplayWithDpValue:(id)dpValue;
@end

@interface ThingSmartLightDp : ThingSmartDp
@property (nonatomic, assign, readonly) NSUInteger lightHueMin;
@property (nonatomic, assign, readonly) NSUInteger lightHueMax;
@property (nonatomic, assign, readonly) NSUInteger currentLightHue;
- (NSString *)lightHueDsecLocalizedKey:(NSUInteger)lightHue;

@property (nonatomic, assign, readonly) NSUInteger lightSaturationMin;
@property (nonatomic, assign, readonly) NSUInteger lightSaturationMax;
@property (nonatomic, assign, readonly) NSUInteger currentLightSaturatio;

@property (nonatomic, assign, readonly) NSUInteger lightValueMin;
@property (nonatomic, assign, readonly) NSUInteger lightValueMax;
@property (nonatomic, assign, readonly) NSUInteger currentLightValue;

@property (nonatomic, assign, readonly) BOOL v2Type;

- (nullable NSDictionary *)publishCommandsWithLightHue:(NSUInteger)lightHue
                                       lightSaturation:(NSUInteger)lightSaturation
                                            lightValue:(NSUInteger)lightValue;
@end


@interface ThingSmartSwitchDp : NSObject
@property (nonatomic, assign, readonly) BOOL switchStatus;

/// Whether the switch only write but does not report style
@property (nonatomic, assign, readonly) BOOL writeOnlySwitch;

- (nullable NSDictionary *)publishSwitchCommands:(BOOL)open;
@end
NS_ASSUME_NONNULL_END

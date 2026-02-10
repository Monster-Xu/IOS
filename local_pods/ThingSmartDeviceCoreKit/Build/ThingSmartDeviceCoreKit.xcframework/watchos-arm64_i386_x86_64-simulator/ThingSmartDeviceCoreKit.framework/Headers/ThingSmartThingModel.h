//
//  ThingSmartThingModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>
#import "ThingSmartSchemaPropertyModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartThingServiceModel;
@class ThingSmartThingProperty;
@class ThingSmartThingAction;
@class ThingSmartThingEvent;

@interface ThingSmartThingModel : NSObject
/// The thing model's id.
@property (nonatomic, strong) NSString *modelId;
/// The thing model's product id.
@property (nonatomic, strong) NSString *productId;
/// The thing model's product version.
@property (nonatomic, strong) NSString *productVersion;
/// The thing model's services.
@property (nonatomic, strong) NSArray<ThingSmartThingServiceModel *> *services;
/// The thing model's extensions.
@property (nonatomic, strong) NSDictionary *extensions;

/// Transfer properties to dps formate
///
/// Example:
/// Input:
/// {
///   "code_name": {
///     "value": "xxx",
///     "time": 1234567890
///   }
/// }
/// The property's code="code_name", abilityId="101".
/// Output:
/// {
///   "dps": {
///     "101": "xxx"
///   },
///   "dpsTime": {
///     "101": 1234567890
///   }
/// }
///
/// @param properties properties
- (NSDictionary *)dpsFromProperties:(NSDictionary *)properties;

@end

@interface ThingSmartThingServiceModel : NSObject
/// The list of properties.
@property (nonatomic, strong) NSArray<ThingSmartThingProperty *> *properties;
/// The list of acrtions.
@property (nonatomic, strong) NSArray<ThingSmartThingAction *> *actions;
/// The list of events.
@property (nonatomic, strong) NSArray<ThingSmartThingEvent *> *events;
@end

@interface ThingSmartThingProperty : NSObject
/// The property id.
@property (nonatomic, assign) NSInteger abilityId;
/// The property code.
@property (nonatomic, strong) NSString *code;
/// The access mode.
///   - rw: send and report
///   - ro: only report
///   - wr: only send.
@property (nonatomic, strong) NSString *accessMode;
/// The type spec.
@property (nonatomic, strong) NSDictionary *typeSpec;
/// The default value.
@property (nonatomic, strong) id defaultValue;
@end
  
@interface ThingSmartThingAction : NSObject
/// The action id.
@property (nonatomic, assign) NSInteger abilityId;
/// The action code.
@property (nonatomic, strong) NSString *code;
/// The input params of action.
@property (nonatomic, strong) NSArray *inputParams;
/// The output params of action.
@property (nonatomic, strong) NSArray *outputParams;
@end

@interface ThingSmartThingEvent : NSObject
/// The event id.
@property (nonatomic, assign) NSInteger abilityId;
/// The event code.
@property (nonatomic, strong) NSString *code;
/// The output params of event.
@property (nonatomic, strong) NSArray *outputParams;

@end

NS_ASSUME_NONNULL_END

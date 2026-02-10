//
//  ThingSmartSchemaModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartSchemaModel
#define ThingSmart_ThingSmartSchemaModel

#import <Foundation/Foundation.h>
#import "ThingSmartSchemaPropertyModel.h"

/// The device schema.
@interface ThingSmartSchemaModel : NSObject

/// The DP ID.
@property (nonatomic, strong) NSString     *dpId;

/// The DP code.
@property (nonatomic, strong) NSString     *code;

/// The name of the DP.
@property (nonatomic, strong) NSString     *name;

/// Reads and writes attributes of the DP. rw: send and report | ro: only report | wr: only send.
@property (nonatomic, strong) NSString     *mode;

/// The type of DP. obj: numeric, character, Boolean, enumeration, and fault | raw: the pass-through type.
@property (nonatomic, strong) NSString     *type;

/// The icon name of the DP.
@property (nonatomic, strong) NSString     *iconname;

/// The DP property.
@property (nonatomic, strong) ThingSmartSchemaPropertyModel *property;

/// The extra content.
@property (nonatomic, strong, nullable) NSString *extContent;

@end

#endif

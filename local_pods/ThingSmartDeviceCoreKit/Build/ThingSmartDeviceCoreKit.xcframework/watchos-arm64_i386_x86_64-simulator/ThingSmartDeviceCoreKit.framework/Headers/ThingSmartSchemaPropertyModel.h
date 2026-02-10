//
//  ThingSmartSchemaPropertyModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartSchemaPropertyModel
#define ThingSmart_ThingSmartSchemaPropertyModel

#import <Foundation/Foundation.h>

@class ThingSmartSchemaPropertyModel;

/// The device schema property.
@interface ThingSmartSchemaPropertyModel : NSObject

/// The type of object. enum: enumerated | bool: Boolean | string: character | value: numeric | bitmap: fault | array: list | struct: struct properties.
@property (nonatomic, strong) NSString   *type;

/// The unit, such as °C.
@property (nonatomic, strong, null_unspecified) NSString   *unit;

/// The minimum value of the numeric type.
@property (nonatomic, assign) double     min;

/// The maximum value of the numeric type.
@property (nonatomic, assign) double     max;

/// The numerical step.
@property (nonatomic, assign) double     step;

/// The exponent of 10 in the numeric type, multiplied by the corresponding transmission value, is equal to the actual value and is used to avoid fractional transmission.
@property (nonatomic, assign) NSInteger  scale;

/// The maximum number of bits of the fault type.
@property (nonatomic, assign) NSInteger  maxlen;

/// Detailed description of the fault type.
@property (nonatomic, strong, null_unspecified) NSArray    *label;

/// The scope of the enumeration type.
@property (nonatomic, strong, null_unspecified) NSArray    *range;

/// The specified value.
@property (nonatomic, assign) NSInteger selectedValue;

/// Detailed descroption of the struct type.
@property (nonatomic, strong, nullable) NSDictionary *properties;

/// The maximum size of the array type.
@property (nonatomic, assign) NSInteger  maxSize;

/// The element type spec of the array type.
@property (nonatomic, strong, nullable) NSDictionary *elementTypeSpec;

@end

#endif

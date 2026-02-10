//
//  ThingSmartCoreCache.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
@interface ThingSmartCoreCache <__covariant KeyType : id<NSCopying>, __covariant ObjectType> : NSObject

/// The cache name, equal `cacheWithName:`
@property (nullable, copy, readonly) NSString *name;

+ (instancetype)cacheWithName:(NSString *)name;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSArray<ObjectType> *)allObjects;
- (NSArray<KeyType> *)allKeys;

- (void)setObject:(ObjectType)object forKey:(KeyType)key;

- (nullable ObjectType)objectForKey:(KeyType)key;

- (BOOL)containsObjectForKey:(KeyType)key;

- (void)removeObjectForKey:(KeyType)key;

/// Remove all cached objects.
- (void)removeAllObjects;

- (NSUInteger)count;

@end

@protocol ThingSmartCoreCacheProtocol <NSObject>

@required
- (const id<NSCopying>)cacheKey;

@optional
+ (nonnull NSString *)cacheName;

@end

/// Quick Cache Any Object
@interface ThingSmartCoreCache<__covariant KeyType : id<NSCopying>, __covariant ObjectType> (CacheObject)

+ (instancetype)cacheWithClass:(Class<ThingSmartCoreCacheProtocol>)aClass;

/// Cache a object, the object must implement the `ThingSmartCoreCacheProtocol` method at the first time.
- (void)cacheObject:(ObjectType<ThingSmartCoreCacheProtocol>)object;

/// Cache a set of objects, the objects must implement the `ThingSmartCoreCacheProtocol` method at the first time.
- (void)cacheObjects:(NSArray<ObjectType<ThingSmartCoreCacheProtocol>> *)objects;

/// Remove a object, the object must implement the `ThingSmartCoreCacheProtocol` method at the first time.
- (void)removeObject:(ObjectType<ThingSmartCoreCacheProtocol>)object;

/// Cache a object, the object must implement the `+ (nonnull NSString *)cacheName` and `ThingSmartCoreCacheProtocol` method at the first time.
+ (void)cacheObject:(ObjectType<ThingSmartCoreCacheProtocol>)object;

/// Cache a set of objects, the objects must implement the `ThingSmartCoreCacheProtocol` method at the first time.
+ (void)cacheObjects:(NSArray<ObjectType<ThingSmartCoreCacheProtocol>> *)objects;

/// Remove a object, the object must implement the `ThingSmartCoreCacheProtocol` method at the first time.
+ (void)removeObject:(ObjectType<ThingSmartCoreCacheProtocol>)object;

#pragma mark - With Class

+ (nullable ObjectType)objectForKey:(KeyType)key withClass:(Class<ThingSmartCoreCacheProtocol>)aClass;

+ (BOOL)containsObjectForKey:(KeyType)key withClass:(Class<ThingSmartCoreCacheProtocol>)aClass;

+ (void)removeObjectForKey:(KeyType)key withClass:(Class<ThingSmartCoreCacheProtocol>)aClass;

@end

NS_ASSUME_NONNULL_END

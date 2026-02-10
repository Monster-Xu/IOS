//
//  ThingBLEGCDTimer.h
//  ThingSmartBLEKit
//
//  Created by milong on 2020/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEGCDTimer : NSObject

@property (readonly) NSTimeInterval interval;

@property (readonly) id _Nullable userInfo;

@property (atomic, assign) NSTimeInterval tolerance;


+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                                       target:(id)aTarget
                                     selector:(SEL)aSelector
                                     userInfo:(nullable id)userInfo
                                      repeats:(BOOL)repeats
                                dispatchQueue:(dispatch_queue_t)dispatchQueue;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                                     userInfo:(nullable id)userInfo
                                      repeats:(BOOL)repeats
                                dispatchQueue:(dispatch_queue_t)dispatchQueue
                                        block:(void (^)(ThingBLEGCDTimer *timer))block;

- (void)fire;

- (void)invalidate;

- (void)pause;

@end

NS_ASSUME_NONNULL_END

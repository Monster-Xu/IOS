//
//  ThingBLEAudioAlarmClockModel.h
//  ThingSmartBLEKit
//
//  Created by tjl on 2021/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEAudioAlarmClockModel : NSObject
// 0 - set , 1 - cancel
@property (nonatomic, assign) NSInteger cmd;
// 0 - timing , 1 - alarm clock , 2 - remind
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *md5Token;

@property (nonatomic, assign) NSInteger time;

@property (nonatomic, assign) NSInteger LoopCount;

@property (nonatomic, assign) NSInteger loopPauseInMilliSeconds;

@property (nonatomic, copy) NSString *reminderText;

@end

NS_ASSUME_NONNULL_END

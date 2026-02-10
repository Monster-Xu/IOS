//
//  LocationManager.h
//  AIToys
//
//  Created by xuxuxu on 2026/1/19.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (instancetype)sharedInstance;
- (void)getCurrentLocationWithCompletion:(void(^)(double latitude, double longitude, NSError *error))completion;

@end




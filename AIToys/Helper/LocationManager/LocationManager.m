//
//  LocationManager.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/19.
//



#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^locationCompletion)(double latitude, double longitude, NSError *error);
@end

@implementation LocationManager

+ (instancetype)sharedInstance {
    static LocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLocationManager];
    }
    return self;
}

- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
}

- (void)getCurrentLocationWithCompletion:(void(^)(double latitude, double longitude, NSError *error))completion {
    self.locationCompletion = completion;
    
    if (@available(iOS 8.0, *)) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    if (location && self.locationCompletion) {
        self.locationCompletion(location.coordinate.latitude, location.coordinate.longitude, nil);
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationCompletion) {
        self.locationCompletion(0, 0, error);
    }
    [self.locationManager stopUpdatingLocation];
}

@end



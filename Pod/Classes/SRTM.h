//
//  SRTM.h
//  SRTM
//
//  Created by Tracy Harton on 10/18/12.
//  Copyright (c) 2012 Amphibious Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SRTM : NSObject

+ (SRTM *)sharedSingleton;

- (CLLocationDistance) elevationForCoordinate:(CLLocationCoordinate2D) coordinate;

@end

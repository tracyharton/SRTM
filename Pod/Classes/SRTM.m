//
//  SRTM.m
//  SRTM
//
//  Created by Tracy Harton on 10/18/12.
//  Copyright (c) 2012 Amphibious Technologies LLC. All rights reserved.
//

#import "SRTM.h"

@implementation SRTM

static SRTM *sharedSingleton = nil;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[SRTM alloc] init];
    }
}

+ (SRTM *)sharedSingleton
{
    return sharedSingleton;
}

const unsigned kMaxCol = 1201;
const unsigned kMaxRow = 1201;

- (CLLocationDistance) elevationFrom:(FILE*)file X:(unsigned)x Y:(unsigned)y
{
    int16_t elevation = INT16_MIN; // standard for void

    long seek = sizeof(int16_t)*((kMaxCol*y)+x);    
    fseek(file, seek, SEEK_SET);

    fread(&elevation, sizeof(int16_t), 1, file);

    elevation = CFSwapInt16BigToHost(elevation);
            
    return (CLLocationDistance)elevation;
}

- (CLLocationDistance) elevationForCoordinate:(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D lowerLeftCoordinate = CLLocationCoordinate2DMake(floor(coordinate.latitude), floor(coordinate.longitude));
    
    NSString *hgtName = [NSString stringWithFormat:@"%c%02d%c%03d.hgt",
                          (lowerLeftCoordinate.latitude < 0.0) ? 'S' : 'N',
                          (int)fabs(lowerLeftCoordinate.latitude),
                          (lowerLeftCoordinate.longitude < 0.0) ? 'W' : 'E',
                          (int)fabs(lowerLeftCoordinate.longitude)];
    
    
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSString *hgtPath = [rootPath stringByAppendingPathComponent:hgtName];
                           
    FILE *file = fopen([hgtPath UTF8String], "r");
    
    CLLocationDistance elevation = 0.0;

    if(file)
    {
        unsigned x = (unsigned)((coordinate.longitude - lowerLeftCoordinate.longitude)*(kMaxCol-1));
        unsigned y = (unsigned)((coordinate.latitude - lowerLeftCoordinate.latitude)*(kMaxRow-1));
        
        elevation = [self elevationFrom:file X:x Y:y];
        fclose(file);
    }
    else
    {
        NSLog(@"ERROR: Cannot load elevation data from %@", hgtPath);
    }
    
    //DDLogVerbose(@"elevation: %f,%f -> %f", coordinate.latitude, coordinate.longitude, elevation);
    
    return(elevation);
}

@end

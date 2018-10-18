/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif


/** MCELocationDatabase manages the database that holds the synced locations from the server. */
@interface MCELocationDatabase : NSObject

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCELocationDatabase * sharedInstance NS_SWIFT_NAME(shared);

/** This method returns the nearby sycned geofences from the server. */
-(NSMutableSet*)geofencesNearCoordinate: (CLLocationCoordinate2D)coordinate radius: (double)radius;

/** This method returns the beacon regions synced from the server. */
-(NSMutableSet*)beaconRegions;

@end

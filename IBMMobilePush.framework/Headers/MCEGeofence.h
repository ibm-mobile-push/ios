/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

@class MCEDatabase;

#import "MCEArea.h"

/**
 MCEGeofence represents a circular geographic region that is synced from the server
 */
@interface MCEGeofence : MCEArea

/**
 locationId represents the unique key for this iBeacon on the server.
 */
@property NSString * locationId;

/**
 isCustom is true if the geofence is defined by behavior and false otherwise.
 */
@property BOOL isCustom;

/**
 region provides a core location circular region for the geofence.
 */
@property (readonly) CLCircularRegion * region;

@end

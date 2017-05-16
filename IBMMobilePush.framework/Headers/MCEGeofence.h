/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;
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

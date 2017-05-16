/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;
@import CoreLocation;

/** MCELocationDatabase manages the database that holds the synced locations from the server. */
@interface MCELocationDatabase : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** This method returns the nearby sycned geofences from the server. */
-(NSMutableSet*)geofencesNearCoordinate: (CLLocationCoordinate2D)coordinate radius: (double)radius;

/** This method returns the beacon regions synced from the server. */
-(NSMutableSet*)beaconRegions;

@end

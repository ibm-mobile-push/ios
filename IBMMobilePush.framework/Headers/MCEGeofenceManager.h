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

@interface MCEGeofenceManager : NSObject <CLLocationManagerDelegate>
+ (instancetype)sharedInstance;
-(NSMutableSet *)geofencesNearCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)resetReferenceLocation;
-(void)updateGeofences;
-(void)updateVisitTracking;
@end

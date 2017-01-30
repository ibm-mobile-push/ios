/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;
@import CoreLocation;

@interface MCELocationDatabase : NSObject
+ (instancetype)sharedInstance;
-(NSMutableSet*)geofencesNearLatitude: (double)latitude longitude:(double)longitude radius: (double)radius;
-(BOOL)upsertLocations:(NSArray*)locations;
-(BOOL)deleteLocations:(NSArray*)locationIds;
-(void)clearDatabase;
-(BOOL)import:(NSDictionary*)json;
-(NSString*)locationIdForBeaconMajor: (NSNumber*)major minor: (NSNumber*)minor;
-(NSMutableSet*)beaconRegions;
@end

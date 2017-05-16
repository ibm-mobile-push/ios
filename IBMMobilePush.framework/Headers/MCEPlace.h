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
@import CoreLocation;
@class MCEResultSet;
@class MCEDatabase;

#import "MCEArea.h"

@interface MCEPlace : MCEArea <NSCopying>
@property NSString * name;
@property NSArray * address;
@property long placeId;
@property NSDate * lastUpdated;

+ (instancetype) placeWithPlaceId:(double)placeId database:(MCEDatabase*)db;

+ (instancetype) placeWithResultSet:(MCEResultSet*)resultSet;
- (instancetype) initWithResultSet:(MCEResultSet*)resultSet;

+ (instancetype) placeWithLatitude: (double)latitude longitude: (double)longitude radius:(double)radius date: (NSDate*)date;
- (instancetype) initWithLatitude: (double)latitude longitude: (double)longitude radius:(double)radius date: (NSDate*)date;

+ (instancetype) placeWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius date:(NSDate*)date;
- (instancetype) initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius date:(NSDate*)date;

- (void) geocodeWithCallback:(void (^)(NSString * name, NSArray * address, NSError * error))callback;

+ (void) createTableWithDatabase:(MCEDatabase*)db;
+ (void) cleanTableWithDatabase:(MCEDatabase*)db;

+ (MCEPlace*) placeAtCoordinate: (CLLocationCoordinate2D) coordinate withDatabase:(MCEDatabase *)db;
+ (MCEPlace*) insertPlaceAtCoordinate: (CLLocationCoordinate2D) coordinate date:(NSDate*)date withDatabase:(MCEDatabase *)db;
+ (NSDictionary*) placesWithDatabase:(MCEDatabase*)db;
-(BOOL)updateDate:(NSDate*)date withDatabase:(MCEDatabase *)db;

@end

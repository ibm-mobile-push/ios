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

@class MCEResultSet;
@class MCEDatabase;
@class MCEPlace;

@interface MCEPlaceVisit : NSObject <NSCopying>

@property long placeVisitId;
@property long placeId;
@property NSDate * arrivalDate;
@property NSDate * departureDate;
@property double hours;
@property long arrivalDateInteger;
@property long departureDateInteger;

+(instancetype) placeVisitWithResultSet:(MCEResultSet*)resultSet;
-(instancetype) initWithResultSet:(MCEResultSet*)resultSet;

+(instancetype) placeVisitWithPlace: (MCEPlace*)place arrivalDate:(NSDate *)arrivalDate departureDate:(NSDate *)departureDate;

+(void)createTableWithDatabase:(MCEDatabase*)db;
+(void)cleanTableWithDatabase:(MCEDatabase*)db;

-(BOOL)insertVisitWithDatabase:(MCEDatabase*)db;

+(NSArray*)visitsForPlace:(MCEPlace*)place withDatabase:(MCEDatabase*)db;
@end

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

@interface MCEPlaceDailyVisit : NSObject <NSCopying>
{
    NSDate * _visitDate;
}
@property long placeDailyVisitId;
@property long placeId;
@property NSDate * visitDate;
@property double hours;
@property long visitDateInteger;

+(instancetype) placeVisitWithResultSet:(MCEResultSet*)resultSet;
-(instancetype) initWithResultSet:(MCEResultSet*)resultSet;

+(instancetype) placeVisitWithPlace: (MCEPlace*)place date: (NSDate*)date hours: (double)hours;

+(void)createTableWithDatabase:(MCEDatabase*)db;
+(void)cleanTableWithDatabase:(MCEDatabase*)db;
-(BOOL)isReadyWithDatabase:(MCEDatabase*)db;
+(BOOL)insertVisitsForPlace:(MCEPlace*)place arrivalDate:(NSDate*)arrivalDate departureDate:(NSDate*)departureDate withDatabase:(MCEDatabase*)db;

+(NSArray*)dailyVisitsForPlace:(MCEPlace*)place withDatabase:(MCEDatabase*)db;
@end

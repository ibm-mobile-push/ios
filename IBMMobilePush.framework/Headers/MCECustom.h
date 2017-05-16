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

@class MCEDatabase, MCEResultSet, MCEVisitOperation, MCEPlace;

@interface MCECustom : NSObject <NSCopying>

@property NSString * locationId;
@property double radius;
@property NSDictionary * rules;

+ (void) createTableWithDatabase:(MCEDatabase*)db;
+ (void) addDefaultValuesWithDatabase:(MCEDatabase*)db;

+(NSArray*)customsWithDatabase:(MCEDatabase*)db;
+(instancetype)customWithResultSet:(MCEResultSet*)resultSet;
-(instancetype)initWithResultSet:(MCEResultSet*)resultSet;;
-(double) deltaForOperation: (MCEVisitOperation*) operation forPlace:(MCEPlace*)place;
+(BOOL)clearDatabase:(MCEDatabase*) db;
+(BOOL)deleteCustomWithLocationId: (NSString*)locationId database:(MCEDatabase*) db;
+(BOOL)upsertRules: (NSArray*)rules radius: (double)radius locationId:(NSString*)locationId withDatabase:(MCEDatabase*)db;
+ (instancetype) customWithLocationId: (NSString*) locationId withDatabase: (MCEDatabase*) db;
@end

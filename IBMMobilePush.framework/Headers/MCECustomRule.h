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

@class MCECustom, MCEDatabase;

@interface MCECustomRule : NSObject <NSCopying>

@property NSString * locationId;
@property NSString * name;
@property double threshold;
@property NSString * operation;
@property double delta;

+ (void) createTableWithDatabase:(MCEDatabase*)db;
+ (void) addDefaultValuesWithDatabase:(MCEDatabase*)db;
+ (NSDictionary*) rulesForCustom: (MCECustom*)custom withDatabase: (MCEDatabase*)db;
-(BOOL)matches:(double)value;
+(BOOL)deleteForLocationId: (NSString*)locationId database:(MCEDatabase*) db;
+(BOOL)clearDatabase:(MCEDatabase*) db;
+(instancetype)customRuleWithName: (NSString*)name threshold: (double)threshold operation: (NSString*)operation delta: (double)delta locationId: (NSString*) locationId;
-(BOOL)insertWithDatabase:(MCEDatabase*)db;
@end

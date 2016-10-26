/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;

@class MCEResultSet;

/** The MCEEvent class represents events to be sent to the server via the MCEEventClient or MCEEventService classes. */
@interface MCEEvent : NSObject

/** The type property is used to set the type value of the event. */
@property NSString *type;

/** The name property is used to set the name value of the event. */
@property NSString *name;

/** The timestamp property is used to set the timestamp value of the event. */
@property NSDate *timestamp;

/** The attributes property is used to set the attributes value of the event. */
@property NSDictionary *attributes;

/** The attribution property is used to set the attribution value of the event. */
@property NSString *attribution;

/** The toDictionary method is used to return the contents of the MCEEvent object as a dictionary. */
- (NSDictionary*)toDictionary;

/** The fromDictionary: method is used to set the attributes of the event via a dictionary. */
- (void) fromDictionary:(NSDictionary*) dictionary;

-(instancetype)initWithName: (NSString*)name type:(NSString*)type;
-(instancetype)initWithName: (NSString*)name type:(NSString*)type timestamp:(NSDate*)timestamp;
-(instancetype)initWithName: (NSString*)name type:(NSString*)type timestamp:(NSDate*)timestamp attributes:(NSDictionary*)attributes;
-(instancetype)initWithName: (NSString*)name type:(NSString*)type timestamp:(NSDate*)timestamp attributes:(NSDictionary*)attributes attribution: (NSString*)attribution;
-(instancetype) initWithResultSet:(MCEResultSet*)results;

-(NSDictionary*)packageEvent;
+(MCEEvent*)unpackageEvent: (NSDictionary *) packagedEvent;
@end


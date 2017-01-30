/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2014
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;

/** The MCECallbackDatabaseManager class is used to queue callbacks in the Cordova plugin until the JavaScript callback methods are registered with the SDK. */

@class MCEDatabaseQueue, MCEDatabase;
@interface MCECallbackDatabaseManager : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The database queue used by the manager */
@property (nonatomic, strong) MCEDatabaseQueue *databaseQueue;

/** The insertCallback:dictionary: method inserts a callback into the database.
 
 @param callback A name of a callback, later used to retrieve the callback
 @param dictionary A dictionary describing the callback, must be composed of only simple types so NSJSONSerialization can serialize it
 */
- (void) insertCallback:(NSString *) callback dictionary: (NSDictionary*)dictionary;

/** The deleteCallbacksById: method removes the specified callback ids from the database.
 
 @param callbackIds a list of ids returned by selectCallbacks:withBlock: to be removed from the database
 */
- (void) deleteCallbacksById:(NSArray*)callbackIds;

/** The selectCallbacks:withBlock: method returns the original callback dictionaries and a list of associated IDs.
 
 @param callback A name of the callback, used when calling insertCallback:dictionary:
 @param block a code block to execute when callbacks are retrieved from the database
 */

/*
 @param dictionaries an array of dictionaries that were inserted into the databases
 @param ids an array of ids that can be used to clear these callbacks with deleteCallbacksById:
 */
- (void) selectCallbacks: (NSString *) callback withBlock :(void (^)(NSArray * dictionaries, NSArray * ids))block;

@end

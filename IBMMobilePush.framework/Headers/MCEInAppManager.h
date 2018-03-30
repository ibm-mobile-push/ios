/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "MCEInAppMessage.h"

/** The MCEInAppManager class owns and interacts with the inApp database. */
@interface MCEInAppManager : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The processPayload: method reads the incoming APNS payload and if it finds an "inApp" block, it adds the inApp message contained to the database.
 
 @param payload The payload parameter is the incoming APNS payload.
 */
-(void) processPayload:(NSDictionary*)payload;

/** The fetchInAppMessagesForRules:completion: method fetches messages from the database that match one of the provided rule keywords and executes the completion block with those messages found. It doesn't not include messages that are expired, overviewed or not yet triggered.
 
 @param names The rule names that are to be fetched.
 @param completion The completion block is executed after the messages are looked up. It includes a list of messages or an error flag.
 */
-(void) fetchInAppMessagesForRules: (NSArray*)names completion:(void (^)(NSMutableArray * inAppMessages, NSError * error))completion;

/** The incrementView: method increments the number of views in the database for the provided message.
 
 @param inAppMessage The inAppMessage parameter specifies the specific message to increment.
 */
-(void) incrementView:(MCEInAppMessage*)inAppMessage;

/** The executeRule: method finds messages that match the specified rule keyword strings and immediately executes them.
 
 @param rules The rules array includes rule keyword strings to look for.
 */
-(void) executeRule: (NSArray*)rules;

/** The disable: method removes an inAppMessage from the database.
 
 @param inAppMessage the message object to be deleted.
 */
-(void)disable:(MCEInAppMessage*)inAppMessage;

-(MCEInAppMessage*) inAppMessageById:(NSString*)inAppMessageId;

@end

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

@class MCETaskQueue;
@class MCEEvent;
@class MCEInboxMessage;

/** The MCEEventService class allows the developer to queue events to the server. If errors occur the update will retry automatically and back-off as needed. */

@interface MCEEventService : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The addEvent:immediate: method is used to add an event to the event queue and optionally flush the queue.
 
 @param event An instance of MCEEvent to be added to the event queue
 @param immediate When set to TRUE, the queue is flushed immediately, sending all events queued.
*/
- (void) addEvent: (MCEEvent *) event immediate:(BOOL) immediate;

/** The sendEvents method flushes the queue to the server on demand. */
- (void) sendEvents;

/** Record a view of an inbox message */
-(void)recordViewForInboxMessage:(MCEInboxMessage*)inboxMessage attribution: (NSString*)attribution;

-(void)recordViewForInboxMessage:(MCEInboxMessage*)inboxMessage attribution: (NSString*)attribution mailingId: (NSString*)mailingId;

/** Record if push is enabled or disabled */
-(void) sendPushEnabledEvent;

@end

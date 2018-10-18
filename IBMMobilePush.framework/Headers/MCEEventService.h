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

@class MCETaskQueue;
@class MCEEvent;
@class MCEInboxMessage;

/** The MCEEventService class allows the developer to queue events to the server. If errors occur the update will retry automatically and back-off as needed. */

@interface MCEEventService : NSObject

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCEEventService * sharedInstance NS_SWIFT_NAME(shared);

/** The addEvent:immediate: method is used to add an event to the event queue and optionally flush the queue.
 
 @param event An instance of MCEEvent to be added to the event queue
 @param immediate When set to TRUE, the queue is flushed immediately, sending all events queued.
*/
- (void) addEvent: (MCEEvent *) event immediate:(BOOL) immediate;

/** The sendEvents method flushes the queue to the server on demand. */
- (void) sendEvents;

/** Record a view of an inbox message
 @param inboxMessage An MCEInboxMessage object to record view for
 @param attribution A string representing the campaign name or attribution of the push message associated with the view event.
 
 Please note that recordViewForInboxMessage:attribution: is deprecated, please use recordViewForInboxMessage:attribution:mailingId: instaed.
 */
-(void)recordViewForInboxMessage:(MCEInboxMessage*)inboxMessage attribution: (NSString*)attribution __attribute__ ((deprecated));

/** Record a view of an inbox message including a mailing id
 @param inboxMessage An MCEInboxMessage object to record view for
 @param attribution A string representing the campaign name or attribution of the push message associated with the view event.
 @param mailingId A string representing the mailing id of the push message associated with the view event.
 */
-(void)recordViewForInboxMessage:(MCEInboxMessage*)inboxMessage attribution: (NSString*)attribution mailingId: (NSString*)mailingId;

#if TARGET_OS_WATCH == 0
/** Record if push is enabled or disabled */
-(void) sendPushEnabledEvent;
#endif

@end

/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import UIKit;
@class MCEInboxMessage;

/** The MCEInboxDatabase class owns and interacts with the inbox database. */
@interface MCEInboxDatabase : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The inboxMessagesAscending: method retrieves an NSArray of MCEInboxMessage objects from the inbox database.

 @param ascending A boolean value that toggles if the contents should be sorted ascending (TRUE) or descending (FALSE)
 @return Returns an NSArray of MCEInboxMessage objects or a nil value in the case of failure.
 */
-(NSMutableArray*)inboxMessagesAscending:(BOOL)ascending;

/** The inboxMessageWithInboxMessageId: method retrieves a single MCEInboxMessage object from the inbox database by inboxMessageId.
 
 @param inboxMessageId A unique identifier for the inbox message.
 @return Returns a single MCEInboxMessage object or a nil value in the case of failure.
 */
-(MCEInboxMessage*)inboxMessageWithInboxMessageId:(NSString*)inboxMessageId;

/** The inboxMessageWithRichContentId: method returns the latest inbox message for the specified richContentId.
 
 @param richContentId A unique identifier for the rich content.
 @return Returns the most recent MCEInboxMessage object or a nil value in the case of failure. 
 */
-(MCEInboxMessage*)inboxMessageWithRichContentId:(NSString*)richContentId;

@end

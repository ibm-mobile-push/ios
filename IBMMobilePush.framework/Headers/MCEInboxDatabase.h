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
@class MCERichContent, MCEInboxMessage;

/** The MCEInboxDatabase class owns and interacts with the inbox database. */
@interface MCEInboxDatabase : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The fetchInboxMessages: method asynchronously retrieves an NSArray of MCEInboxMessage objects from the inbox database.

 @param ascending A boolean value that toggles if the contents should be sorted ascending (TRUE) or descending (FALSE)
 @param completion This callback returns an NSArray of MCEInboxMessage objects or an NSError in the case of failure.
 */
-(void)fetchInboxMessages:(void (^)(NSMutableArray * inboxMessages, NSError * error))completion ascending:(BOOL)ascending;

/** The fetchRichContentId:completion: method asynchronously retrieves a single MCERichContent object from the inbox database by richContentId.
 
 @param richContentId A unique identifier for the rich content.
 @returns MCERichContent object for specified richContentId.
 */
- (MCERichContent *) fetchRichContentId:(NSString*)richContentId;

/** The fetchInboxMessageId:completion: method retrieves a single MCEInboxMessage object from the inbox database by inboxMessageId.
 
 @param inboxMessageId A unique identifier for the inbox message.
 @param completion This callback returns a single MCEInboxMessage object or an NSError in the case of failure. The NSError could have the domain  "Inbox message not in storage" in the case of the message not being in the database. In this case, you can listen for the NSNotification message MCESyncDatabase and call the syncDatabase method to update the database.
 */
-(void)fetchInboxMessageId:(NSString*)inboxMessageId completion: (void (^)(MCEInboxMessage * inboxMessage, NSError * error))completion;

/** The setReadForInboxMessageId: method sets the read flag for a single message in the inbox database.
 
 @param inboxMessageId A unique identifier for the inbox message.
 */
-(void)setReadForInboxMessageId:(NSString*)inboxMessageId;

/** The setDeletedForInboxMessageId: method sets the deleted flag for a single message in the inbox database.
 
 @param inboxMessageId A unique identifier for the inbox message.
 */
-(void)setDeletedForInboxMessageId:(NSString*)inboxMessageId;

/** The setReadForRichContentId: method sets the read flag for all the messages with the specified richContentId in the inbox database.
 
 @param richContentId A unique identifier for the rich content.
 */
-(void)setReadForRichContentId:(NSString*)richContentId;

/** The fetchInboxMessageViaRichContentId:completion: method returns the first inbox message for the specified richContentId.
 
 @param richContentId A unique identifier for the rich content.
 @param completion This callback returns the most recent MCEInboxMessage object or an NSError message in the case of failure. The NSError could have the domain "Inbox message not in storage" in the case of the message not being in the database. In this case, you can listen for the NSNotification message MCESyncDatabase and call the syncDatabase method to update the database.
 */
-(void)fetchInboxMessageViaRichContentId:(NSString*)richContentId completion: (void (^)(MCEInboxMessage * inboxMessage, NSError * error))completion;

/** The updateDatabase: method updates the local database with the specified list of MCEInboxMessage objects. This is done in an upsert style operation.
 
 @param messages An array of MCEInboxMessage objects.
 */
-(void)updateDatabase: (NSArray*)messages;

@end

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

/** The MCEInboxMessage class represents an inbox message that is sent to the user. The richContentId can be used to query the MCERichContent object that represents the content of the message. */
@interface MCEInboxMessage : NSObject

/** inboxMessageId is a unique identifier for the inbox message. */
@property NSString * inboxMessageId;

/** richContentId is a unique identifier for the rich content. */
@property NSString * richContentId;

/** expirationDate is the date that the message is no longer available for viewing. */
@property NSDate * expirationDate;

/** sendDate is the date that the message is sent to the user. */
@property NSDate * sendDate;

/** template is an identifier that matches a template object in the MCETemplateRegistry. */
@property NSString * template;

/** attribution is an identifier that specifies a campaign. */
@property NSString * attribution;

@property NSString * mailingId;

/** isRead is TRUE when the message has been read and FALSE by default. */
@property (readonly) BOOL isRead;

/** isDeleted is TRUE when the message no longer displays in the message list and is FALSE by default. */
@property (readonly) BOOL isDeleted;


/** The initWithResultSet: method initializes a MCEInboxMessage object through a database result set.
 
 @param results A database result set.
 @return Returns the initialized object.
 */
-(instancetype)initWithResultSet:(MCEResultSet*)results;

/** The inboxMessageFromResultSet: method allocates and initializes a MCEInboxMessage object through a database result set.
 
 @param results A database result set.
 @return Returns the initialized object.
 */
+(instancetype)inboxMessageFromResultSet:(MCEResultSet*)results;

/** The initWithPayload: method initializes a MCEInboxMessage object through a response from the server API.
 
 @param payload the response from the server API that represents a single inbox message.
 @return Returns the initialized object.
 */
-(instancetype)initWithPayload:(NSDictionary*)payload;

/** The inboxMessageFromPayload: method allocates and initializes a MCEInboxMessage object through a response from the server API.
 
 @param payload the response from the server API that represents a single inbox message.
 @return Returns the initialized object.
 */
+(instancetype)inboxMessageFromPayload:(NSDictionary*)payload;

/** The isExpired method returns TRUE when the message is expired and FALSE otherwise. */
-(BOOL)isExpired;

/** The read method sets the isRead flag to TRUE and updates the local inbox database. */
-(void)read;

/** The delete method sets the isDeleted flag to TRUE and updates the local inbox database. */
-(void)delete;

@end

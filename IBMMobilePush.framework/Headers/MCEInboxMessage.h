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

/** The MCEInboxMessage class represents an inbox message that is sent to the user. */
@interface MCEInboxMessage : NSObject

/** inboxMessageId is a unique identifier for the inbox message. */
@property NSString * inboxMessageId;

/** content is where the template's content is stored. The elements of this dictionary are undefined by the SDK and consist of whatever is sent. */
@property NSDictionary * content;

/** richContentId is a unique identifier for the rich content. */
@property NSString * richContentId;

/** expirationDate is the date that the message is no longer available for viewing. */
@property NSDate * expirationDate;

/** sendDate is the date that the message is sent to the user. */
@property NSDate * sendDate;

/** template is an identifier that matches a template object in the MCETemplateRegistry. */
@property NSString * templateName;

/** attribution is an identifier that specifies a campaign. */
@property NSString * attribution;

@property NSString * mailingId;

/** isRead is TRUE when the message has been read and FALSE by default. */
@property BOOL isRead;

/** isDeleted is TRUE when the message no longer displays in the message list and is FALSE by default. */
@property BOOL isDeleted;

/** The isExpired property returns TRUE when the message is expired and FALSE otherwise. */
@property (readonly) BOOL isExpired;

@end

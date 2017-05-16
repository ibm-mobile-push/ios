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

/** The MCEWebViewActionDelegate class provides a UIWebViewDelegate that can respond to actionid: scheme actions tied to the MCEActionRegistry. */
@interface MCEWebViewActionDelegate : NSObject <UIWebViewDelegate>

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The actions that should be responded to. In the format of actionid -> { action dictionary }. */
@property NSDictionary * actions;

/** Source to be reported in event reporting. */
@property NSString * eventSource;

/** Additional attributes to be included in event reporting. */
@property NSDictionary * eventAttributes;

/** Payload of message to be included in event reporting. */
@property NSDictionary * eventPayload;

/** Convenience method for setting properties for inbox messages */
-(void)configureForSource:(NSString*)source inboxMessage:(MCEInboxMessage*)inboxMessage actions:(NSDictionary*)actions;

/** Convenience method for setting properties */
-(void)configureForSource:(NSString*)source attributes:(NSDictionary*)attributes attribution: (NSString*)attribution actions:(NSDictionary*)actions;

/** Convenience method for setting properties */
-(void)configureForSource:(NSString*)source attributes:(NSDictionary*)attributes attribution: (NSString*)attribution mailingId: (NSString*)mailingId actions:(NSDictionary*)actions;

@end

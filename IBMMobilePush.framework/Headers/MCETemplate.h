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

/** The MCETemplateDisplay protocol must be implemented by UIViewControllers to display full page content of inbox messages. */
@protocol MCETemplateDisplay

@property MCEInboxMessage * inboxMessage;

/** Update the view to show the MCEInboxMessage assigned.
 */
-(void)setContent;

/** The setLoading method is used to empty the view controller's display and enable any sort of activity indicators until the message content is delivered. */
-(void)setLoading;

@end

/** The MCETemplatePreview protocol must be implemented by UITableViewCells to display the preview content of an inbox message. UITableViewCells should also implement prepareForReuse and awakeFromNib methods to clear their contents before the message contents are available. */
@protocol MCETemplatePreview

/** The setRichContent:inboxMessage: method is used to set the current rich content and inbox message values that the UITableViewCell should display.
 
 @param inboxMessage The MCEInboxMessage object that represents a single message in the inbox.
*/

-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage;

@end

/** The MCETemplate protocol is required to implement the template class. It provides the UIViewController and UITableViewCells to display the content of inbox messages. */
@protocol MCETemplate

/** The displayViewController method returns a UIViewController that implements the MCETemplateDisplay protocol that displays a single message on a full screen.
 
 @return Returns a UIViewController that implements the MCETemplateDisplay protocol that displays a single message on a full screen.
 */
-(id<MCETemplateDisplay>)displayViewController;

/** The shouldDisplayInboxMessage: method determines that a message can be opened. This is typically used to disallow expired messages from being opened but can also be used for other criteria.
 
 @param inboxMessage A MCEInboxMessage object.
 @return TRUE if the message can be opened, FALSE otherwise.
 */
-(BOOL)shouldDisplayInboxMessage: (MCEInboxMessage*)inboxMessage;

-(UITableViewCell *) cellForTableView: (UITableView*)tableView inboxMessage:(MCEInboxMessage *)inboxMessage indexPath:(NSIndexPath*)indexPath;

/** Provides a method for changing the height of the UITableView content preview cells.

 @return height in points.
 */
-(float)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath inboxMessage: (MCEInboxMessage*)message;

@end

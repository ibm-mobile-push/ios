/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2014
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

/** The MCEInboxQueueManager class queues and executes tasks serially to the inbox server. */
@interface MCEInboxQueueManager : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The syncInbox method adds a sync task to the queue. First, it connects to the server to download inbox message updates. Next, it updates the local MCEInboxDatabase store. After the update is complete, it sends an NSNotification with the MCESyncDatabase name, and the MCEInboxTableViewController refreshes its contents. Note - only a single sync task is added to the queue at a time. Additional tasks are not added regardless if you make multiple calls while the task is queued or running. */
-(void)syncInbox;

@end

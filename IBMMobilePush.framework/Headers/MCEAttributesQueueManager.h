/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2014
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@class MCETaskQueue;

/** The MCEAttributesQueueManager class allows you to queue attribute updates to the server. If errors occur, the update retries automatically and backs off as needed. */

@interface MCEAttributesQueueManager : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** The attributeQueue method returns the current task queue object that processes updates that are sent to this class. */
- (MCETaskQueue*) attributesQueue;

/** @name Channel Methods */

/** The setChannelAttributes method replaces channel attributes on the server with the specified set of attribute key value pairs.
 
 When the operation completes successfully, it sends a NSNotification with the SetChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the SetChannelAttributesError name; however, it automatically retries as needed.
 */
-(void)setChannelAttributes:(NSDictionary*)attributes;

/** The updateChannelAttributes method adds or updates the specified attributes to the channel record on the server.
 
 When the operation completes successfully, it sends a NSNotification with the UpdateChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the UpdateChannelAttributesError name; however, it automatically retries as needed.
 */
-(void)updateChannelAttributes:(NSDictionary*)attributes;

/** The deleteChannelAttributes method removes the specified keys from the channel record on the server.
 
 When the operation completes successfully, it sends a NSNotification with the DeleteChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the DeleteChannelAttributesError name; however, it automatically retries as needed.
*/
-(void)deleteChannelAttributes:(NSArray*) keys;

/** @name User Methods */

/** The setUserAttributes method replaces user attributes on the server with the specified set of attribute key value pairs.
 
 When the operation completes successfully, it sends a NSNotification with the SetUserAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the SetUserAttributesError name; however, it automatically retries as needed.
 */
-(void)setUserAttributes:(NSDictionary*)attributes;

/** The updateUserAttributes method adds or updates the specified attributes to the user record on the server.
 
 When the operation completes successfully it will send a NSNotification with the name UpdateUserAttributesSuccess.
 When the operation fails it will send a NSNotification with the name UpdateUserAttributesError, however it will automatically retry as needed.
*/
-(void)updateUserAttributes:(NSDictionary*)attributes;

/** The deleteUserAttributes method removes the specified keys from the user record on the server.
 
 When the operation completes successfully, it sends a NSNotification with the DeleteUserAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the DeleteUserAttributesError name; however, it automatically retries as needed.
 */
-(void)deleteUserAttributes:(NSArray*) keys;

@end

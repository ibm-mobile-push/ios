/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


@class MCETaskQueue;

/** The MCEAttributesQueueManager class allows you to queue attribute updates to the server. If errors occur, the update retries automatically and backs off as needed. */

@interface MCEAttributesQueueManager : NSObject

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCEAttributesQueueManager * sharedInstance NS_SWIFT_NAME(shared);

/** @name Channel Methods */

/** The setChannelAttributes method replaces channel attributes on the server with the specified set of attribute key value pairs.
 
 When the operation completes successfully, it sends a NSNotification with the SetChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the SetChannelAttributesError name; however, it automatically retries as needed.
 
 Please note, setChannelAttributes is deprecated.
 */
-(void)setChannelAttributes:(NSDictionary*)attributes __attribute__ ((deprecated));

/** The updateChannelAttributes method adds or updates the specified attributes to the channel record on the server.
 
 When the operation completes successfully, it sends a NSNotification with the UpdateChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the UpdateChannelAttributesError name; however, it automatically retries as needed.
 
 Please note, updateChannelAttributes is deprecated.
 */
-(void)updateChannelAttributes:(NSDictionary*)attributes __attribute__ ((deprecated));

/** The deleteChannelAttributes method removes the specified keys from the channel record on the server.
 
 When the operation completes successfully, it sends a NSNotification with the DeleteChannelAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the DeleteChannelAttributesError name; however, it automatically retries as needed.
 
 Please note, deleteChannelAttributes is deprecated.
*/
-(void)deleteChannelAttributes:(NSArray*) keys __attribute__ ((deprecated));

/** @name User Methods */

/** The setUserAttributes method replaces user attributes on the server with the specified set of attribute key value pairs.
 
 When the operation completes successfully, it sends a NSNotification with the SetUserAttributesSuccess name.
 When the operation fails, it sends a NSNotification with the SetUserAttributesError name; however, it automatically retries as needed.
 
 Please note, setUserAttributes is deprecated. Please use updateUserAttributes to set attribute values, and deleteUserAttributes to clear existing values.
 */
-(void)setUserAttributes:(NSDictionary*)attributes __attribute__ ((deprecated));

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

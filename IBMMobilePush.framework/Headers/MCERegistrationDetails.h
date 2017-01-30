/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2015, 2015
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */
@import Foundation;

/** MCERegistrationDetails provides the userId, channelId and pushToken registration details. You might want to store the userId and channelId on your servers if you want to directly target users and channels. */
@interface MCERegistrationDetails : NSObject

/** Retrieve userId 
 
 @return userId a string value assigned to the user (potentially multiple devices)
*/
+(NSString*)userId;

/** Retrieve channelId 
 
 @return channelId a string value assigned to the channel (device)
*/
+(NSString*)channelId;

/** Set userId
 
 @param userId new string to use as userId
 */
+(void)setUserId:(NSString*)userId;

/** Set channelId

 @param channelId new string to use as channelId
 */
+(void)setChannelId:(NSString*)channelId;

/** Retrieve pushToken
 
 @return pushToken an NSData containing the push token provided by APNS
 */
+(NSData*)pushToken;

/** Set pushToken
 
 @param deviceToken a new NSData to use as the push token
 */
+(void)setPushToken:(NSData*)deviceToken;

/** Is registered with Apple Push Service 
 @return TRUE or FALSE
 */
+(BOOL)apsRegistered;

/** Is registered with IBM Mobile Channel Engagement service
 @return TRUE or FALSE
 */
+(BOOL)mceRegistered;

@end

/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2015, 2017
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */
#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/** MCERegistrationDetails provides the userId, channelId and pushToken registration details. You might want to store the userId and channelId on your servers if you want to directly target users and channels. */
@interface MCERegistrationDetails : NSObject

+ (instancetype)sharedInstance;

/** todo */
@property BOOL userInvalidated;

/** Retrieve userId 
 
 @return userId a string value assigned to the user (potentially multiple devices)
*/
@property NSString * userId;

/** Retrieve channelId 
 
 @return channelId a string value assigned to the channel (device)
*/
@property NSString * channelId;

/** Push Token for APNS registration
 @return pushToken an NSData value representing the push token for the app installation on the device from APNS.
 */
@property NSData * pushToken;

/** Is registered with Apple Push Service
 @return TRUE or FALSE
 */
@property (readonly) BOOL apsRegistered;

/** Is registered with IBM Mobile Channel Engagement service
 @return TRUE or FALSE
 */
@property (readonly) BOOL mceRegistered;


/** Method is deprecated, please use instance method instead. */
+ (BOOL) mceRegistered __attribute__((deprecated));

/** Method is deprecated, please use instance method instead. */
+ (NSString*) channelId __attribute__((deprecated));

/** Method is deprecated, please use instance method instead. */
+ (NSString*) userId __attribute__((deprecated));

/** Method is deprecated, please use instance method instead. */
+ (NSData *) pushToken __attribute__((deprecated));

@property NSString * appKey;

@end

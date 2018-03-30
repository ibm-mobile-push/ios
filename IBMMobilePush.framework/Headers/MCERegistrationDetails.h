/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/** MCERegistrationDetails provides the userId, channelId and pushToken registration details. You might want to store the userId and channelId on your servers if you want to directly target users and channels. */
@interface MCERegistrationDetails : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** When a user has been invalidated and the autoReinitialize flag is false in the MceConfig.json file, this value will be set to true. Applications must check this value if they want to manually reinitialize the registration and when this value is true, applications should execute MceSdk.sharedInstance's manualInitialization method.  */
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


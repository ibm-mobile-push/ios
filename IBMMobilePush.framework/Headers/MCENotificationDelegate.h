/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UserNotifications;
#else
#import <UserNotifications/UserNotifications.h>
#endif

/**
 MCENotificationDelegate provides SDK integration for the UNUserNotificationCenterDelegate methods introduced in iOS 10. 
 */
@interface MCENotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

@end

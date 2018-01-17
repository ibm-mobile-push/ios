/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UserNotifications;
#else
#import <UserNotifications/UserNotifications.h>
#endif

/** Superclass to be used for application's Notification Service for iOS 10+ notification action support. */
@interface MCENotificationService : UNNotificationServiceExtension <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end

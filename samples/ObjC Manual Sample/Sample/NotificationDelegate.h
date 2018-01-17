/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
@import UserNotifications;
#else
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#endif

@interface NotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

@end

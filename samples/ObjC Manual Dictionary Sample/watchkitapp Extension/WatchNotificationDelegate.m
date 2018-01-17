/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "WatchNotificationDelegate.h"
#import <IBMMobilePushWatch/IBMMobilePushWatch.h>

@implementation WatchNotificationDelegate

#pragma mark This method defines if the notification should be shown to the user while the app is open
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
{
    // IBMMobilePush Integration
    NSDictionary * userInfo = notification.request.content.userInfo;
    if(!MCEWatchSdk.sharedInstance.presentNotification || MCEWatchSdk.sharedInstance.presentNotification(userInfo))
    {
        completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
        NSLog(@"User notification presenting %@", userInfo);
    }
    else
    {
        completionHandler(0);
        NSLog(@"Not presenting to user because application presentNotification returned FALSE");
    }
}

#pragma mark Remote or Local notification or notification action clicked, potentially with text input
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0) __TVOS_PROHIBITED
{
    // IBMMobilePush Integration
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"User notification received %@", userInfo);
    
    if([response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier])
    {
        [MCEWatchSdk.sharedInstance performNotificationAction: userInfo];
    }
    else if(response.actionIdentifier)
    {
        [MCEWatchSdk.sharedInstance performNotificationAction: userInfo identifier:response.actionIdentifier];
    }
    
    completionHandler();
}

@end


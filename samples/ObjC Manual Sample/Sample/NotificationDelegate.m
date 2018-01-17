/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "NotificationDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>

@implementation NotificationDelegate

#pragma mark This method defines if the notification should be shown to the user while the app is open
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
{
    // IBMMobilePush Integration
    NSDictionary * userInfo = notification.request.content.userInfo;
    if(!MCESdk.sharedInstance.presentNotification || MCESdk.sharedInstance.presentNotification(userInfo))
    {
        completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
    }
    else
    {
        completionHandler(0);
    }
}

#pragma mark Remote or Local notification or notification action clicked, potentially with text input
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler;
{
    // IBMMobilePush Integration
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    
    if([response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier])
    {
        [[MCESdk sharedInstance] performNotificationAction: userInfo];
    }
    else if([response.actionIdentifier isEqual:UNNotificationDismissActionIdentifier])
    {
    }
    else if([response isKindOfClass:[UNTextInputNotificationResponse class]])
    {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: textResponse.userText];
    }
    else
    {
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: nil];
    }
        
    completionHandler();
}

@end

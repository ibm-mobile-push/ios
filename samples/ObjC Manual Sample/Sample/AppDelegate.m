/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UserNotifications;
@import MessageUI;
#else
#import <UserNotifications/UserNotifications.h>
#import <MessageUI/MessageUI.h>
#endif

#import "AppDelegate.h"
#import "NotificationDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>
#import "MailDelegate.h"

// Action Plugins
#import "ActionMenuPlugin.h"
#import "AddToCalendarPlugin.h"
#import "AddToPassbookPlugin.h"
#import "SnoozeActionPlugin.h"
#import "DisplayWebViewPlugin.h"
#import "TextInputActionPlugin.h"
#import "ExamplePlugin.h"
#import "CarouselAction.h"

// MCE Inbox Plugins
#import "MCEInboxActionPlugin.h"
#import "MCEInboxPostTemplate.h"
#import "MCEInboxDefaultTemplate.h"

// MCE InApp Plugins
#import "MCEInAppVideoTemplate.h"
#import "MCEInAppImageTemplate.h"
#import "MCEInAppBannerTemplate.h"

@interface MyAlertView : UIAlertView
@end

@implementation MyAlertView
@end

@interface MyAlertController : UIAlertController

@end

@implementation MyAlertController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSLog(@"Do customizations here or replace with a duck typed class");
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end

@interface AppDelegate ()
@property NotificationDelegate * notificationDelegate;
@property NSString * string;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MCESdk.sharedInstance handleApplicationLaunch];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"action":@"update",@"standardType":@"dial", @"standardDialValue":@"\"8774266006\"", @"standardUrlValue":@"\"http://ibm.com\"", @"customType":@"sendEmail", @"customValue":@"{\"subject\":\"Hello from Sample App\", \"body\": \"This is an example email body\", \"recipient\":\"fake-email@fake-site.com\"}", @"categoryId":@"example",@"button1":@"Accept",@"button2":@"Reject"}];
    
    if([UNUserNotificationCenter class]) {
        // iOS 10+ Example static action category:
        UNNotificationAction * acceptAction = [UNNotificationAction actionWithIdentifier:@"Accept" title:@"Accept" options:UNNotificationActionOptionForeground];
        UNNotificationAction * fooAction = [UNNotificationAction actionWithIdentifier:@"Foo" title:@"Foo" options:UNNotificationActionOptionForeground];
        UNNotificationAction * rejectAction = [UNNotificationAction actionWithIdentifier:@"Reject" title:@"Reject" options:UNNotificationActionOptionDestructive];
        UNNotificationCategory * category = [UNNotificationCategory categoryWithIdentifier:@"example" actions:@[acceptAction, fooAction, rejectAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        NSSet * applicationCategories = [NSSet setWithObject: category];
        
        // iOS 10+ Push Message Registration
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = MCENotificationDelegate.sharedInstance;
        NSUInteger options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay;
        [center requestAuthorizationWithOptions: options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            [UIApplication.sharedApplication performSelectorOnMainThread:@selector(registerForRemoteNotifications) withObject:nil waitUntilDone:TRUE];
            [center setNotificationCategories: applicationCategories];
        }];
    } else if ([UIApplication.sharedApplication respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8+ Example static action category:
        UIMutableUserNotificationAction * acceptAction = [[UIMutableUserNotificationAction alloc] init];
        [acceptAction setIdentifier: @"Accept"];
        [acceptAction setTitle: @"Accept"];
        [acceptAction setActivationMode: UIUserNotificationActivationModeForeground];
        [acceptAction setDestructive: false];
        [acceptAction setAuthenticationRequired: false];
        
        UIMutableUserNotificationAction * rejectAction = [[UIMutableUserNotificationAction alloc] init];
        [rejectAction setIdentifier: @"Reject"];
        [rejectAction setTitle: @"Reject"];
        [rejectAction setActivationMode: UIUserNotificationActivationModeBackground];
        [rejectAction setDestructive: true];
        [rejectAction setAuthenticationRequired: false];
        
        UIMutableUserNotificationCategory * category = [[UIMutableUserNotificationCategory alloc] init];
        [category setIdentifier: @"example"];
        [category setActions: @[acceptAction, rejectAction] forContext: UIUserNotificationActionContextDefault];
        [category setActions: @[acceptAction, rejectAction] forContext: UIUserNotificationActionContextMinimal];
        NSSet * applicationCategories = [NSSet setWithObject: category];
        
        // iOS 8+ Push Message Registration
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories: applicationCategories];
        [UIApplication.sharedApplication registerUserNotificationSettings:settings];
        [UIApplication.sharedApplication registerForRemoteNotifications];
    } else {
        // iOS < 8 Push Message Registration
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [UIApplication.sharedApplication registerForRemoteNotificationTypes:myTypes];
#pragma GCC diagnostic pop
    }
    
    return YES;
}

-(instancetype)init
{
    if(self=[super init])
    {
        MCESdk.sharedInstance.presentNotification = ^BOOL(NSDictionary * userInfo){
            NSLog(@"Checking if should present notification!");
            
            // return FALSE if you don't want the notification to show to the user when the app is active
            return TRUE;
        };
        
        // This shows how you might overwrite the alert class
        [MCESdk sharedInstance].customAlertViewClass = [MyAlertView class];
        [MCESdk sharedInstance].customAlertControllerClass = [MyAlertController class];

        // Register Inbox plugins
        [MCEInboxActionPlugin registerPlugin];
        [MCEInboxPostTemplate registerTemplate];
        [MCEInboxDefaultTemplate registerTemplate];
        
        // Register InApp Plugins
        [MCEInAppVideoTemplate registerTemplate];
        [MCEInAppImageTemplate registerTemplate];
        [MCEInAppBannerTemplate registerTemplate];
        
        // Register Action Plugins
        [ActionMenuPlugin registerPlugin];
        [ExamplePlugin registerPlugin];
        [AddToCalendarPlugin registerPlugin];
        [AddToPassbookPlugin registerPlugin];
        [SnoozeActionPlugin registerPlugin];
        [DisplayWebViewPlugin registerPlugin];
        [TextInputActionPlugin registerPlugin];
        [CarouselAction registerPlugin];
        
        // Custom Send Email Plugin Example
        [[MCEActionRegistry sharedInstance] registerTarget:[[MailDelegate alloc] init] withSelector:@selector(sendEmail:) forAction:@"sendEmail"];
    }
    return self;
}

#pragma mark Process Static Category No Choice Made
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // IBMMobilePush Integration
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    
    if(!MCESdk.sharedInstance.presentNotification || MCESdk.sharedInstance.presentNotification(userInfo))
    {
        [[MCESdk sharedInstance] presentDynamicCategoryNotification: userInfo];
    }

    // This is just example code on how you might handle a static action category
    if(userInfo[@"aps"] && [userInfo[@"aps"][@"category"] isEqual: @"example"])
    {
        [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Static category handler" message:@"Static Category, no choice made" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    
    // This is required by iOS
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark Local Notification Action Clicked
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    // IBMMobilePush Integration
    [[MCESdk sharedInstance] processDynamicCategoryNotification: notification.userInfo identifier:identifier userText: nil];
    completionHandler();
}

#pragma mark Remote Notification Action Clicked
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    // IBMMobilePush Integration
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    [[MCESdk sharedInstance] processCategoryNotification: userInfo identifier:identifier];

    // This is just example code on how you might handle a static action category
    if(userInfo[@"aps"] && [userInfo[@"aps"][@"category"] isEqual: @"example"])
    {
        NSLog(@"Static Category, %@ button clicked", identifier);

        NSDictionary * values = userInfo[@"category-values"];
        if(values)
        {
            NSString * name = values[@"name"];
            NSNumber * quantity = values[@"quantity"];
            NSNumber * persist = values[@"persist"];
            NSDictionary * other = values[@"other"];
            if(name && quantity && persist && other)
            {
                NSString * message = other[@"deniedMessage"];
                if([identifier isEqual:@"Accept"])
                {
                    [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Static category handler" message:[NSString stringWithFormat: @"User pressed %@ for %@ quantity %@", identifier, name, quantity] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                    return;
                }
                if([identifier isEqual:@"Reject"])
                {
                    [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Static category handler" message:[NSString stringWithFormat: @"User Pressed %@ persistance %d, reason %@", identifier, [persist boolValue], message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
                    return;
                }
            }
        }
        
        [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Static category handler" message:[NSString stringWithFormat: @"Static Category, %@ button clicked", identifier] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];

        // Send event to Xtify Servers
        NSString * eventName = @"Name of event";
        NSString * eventType = @"Type of event";
        NSDictionary * attributes = @{};
        
        NSString * attribution=nil;
        if(userInfo[@"mce"] && userInfo[@"mce"][@"attribution"])
        {
            attribution = userInfo[@"mce"][@"attribution"];
        }
        
        NSString * mailingId=nil;
        if(userInfo[@"mce"] && userInfo[@"mce"][@"mailingId"])
        {
            mailingId = userInfo[@"mce"][@"mailingId"];
        }
        
        MCEEvent * event = [[MCEEvent alloc] init];
        [event fromDictionary: @{ @"name":eventName, @"type":eventType, @"timestamp":[[NSDate alloc]init], @"attributes": attributes}];
        if(attribution)
        {
            event.attribution=attribution;
        }
        if(mailingId)
        {
            event.mailingId=mailingId;
        }
        
        [[MCEEventService sharedInstance] addEvent:event immediate:FALSE];
    }
    
    // This is required by iOS
    completionHandler();
}


#pragma mark Handoff Support
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
{
    // This is needed If you want the Watch to be able to handoff actions to the iPhone
    if([userActivity.activityType isEqual: MCEConfig.sharedInstance.handoffUserActivityName])
    {
        NSDictionary * action = userActivity.userInfo[@"action"];
        NSDictionary * payload = userActivity.userInfo[@"payload"];
        if(action && [action isKindOfClass:NSDictionary.class] && payload && [payload isKindOfClass:NSDictionary.class])
        {
            [[MCEActionRegistry sharedInstance] performAction: action forPayload:payload source: SimpleNotificationSource userText:nil];
            restorationHandler(@[self.window.rootViewController]);
            return TRUE;
        }
        else
        {
            NSLog(@"Could not extract aciton and payload from useractivity");
        }
        return FALSE;
    }
    
    return FALSE;
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    if([userActivityType isEqual: MCEConfig.sharedInstance.handoffUserActivityName])
    {
        return;
    }
    
    // You may have additional error handling here
}

-(BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    // This is needed If you want the Watch to be able to handoff actions to the iPhone
    if([userActivityType isEqual: MCEConfig.sharedInstance.handoffUserActivityName])
    {
        return TRUE;
    }
    
    return FALSE;
}

#pragma mark Location Fetch Support
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    // This is needed to retrieve the location update background fetch
    if(MCESdk.sharedInstance.config.geofenceEnabled)
    {
        MCELocationClient * sync = [[MCELocationClient alloc] init];
        sync.fetchCompletionHandler = completionHandler;
    }
    
    if(!MCESdk.sharedInstance.config.geofenceEnabled)
    {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    if(![[[MCELocationClient alloc] init] handleEventsForBackgroundURLSession: identifier completionHandler: completionHandler])
    {
        // add your background download code here
    }
}

#pragma mark APNS Registration Callbacks

#pragma mark Registered for User Notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // IBMMobilePush Integration
    [MCEEventService.sharedInstance sendPushEnabledEvent];
}

#pragma mark Got remote notification token
-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // IBMMobilePush Integration
    [[MCESdk sharedInstance]registerDeviceToken:deviceToken];
    NSLog(@"deviceToken: %@", [MCEApiUtil deviceToken: MCERegistrationDetails.sharedInstance.pushToken]);
    
    // if this is iOS 7 then the user notification event goes here, else it'll show up in application:didRegisterUserNotificationSettings: above
    if(![application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [MCEEventService.sharedInstance sendPushEnabledEvent];
    }
}

#pragma mark Couldn't get remote notification token
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    // IBMMobilePush Integration
    [[MCESdk sharedInstance]deviceTokenRegistartionFailed];
}

#pragma mark Remote Notification Action Clicked with Text Input
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^_Nonnull __strong)())completionHandler
{
    // IBMMobilePush Integration
    [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:identifier userText: responseInfo[ UIUserNotificationActionResponseTypedTextKey]];
    completionHandler();
}

#pragma mark Local Notification Action Clicked with Text Input
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^_Nonnull __strong)())completionHandler
{
    // IBMMobilePush Integration
    [[MCEInAppManager sharedInstance] processPayload: notification.userInfo];
    [[MCESdk sharedInstance] processDynamicCategoryNotification: notification.userInfo identifier:identifier userText: responseInfo[ UIUserNotificationActionResponseTypedTextKey]];
    
    completionHandler();
}

#pragma mark Remote Notification Clicked
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // IBMMobilePush Integration
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    
    if(!MCESdk.sharedInstance.presentNotification || MCESdk.sharedInstance.presentNotification(userInfo))
    {
        [[MCESdk sharedInstance] presentOrPerformNotification: userInfo];
    }
}

#pragma mark Local Notification Clicked
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // IBMMobilePush Integration
    if(!MCESdk.sharedInstance.presentNotification || MCESdk.sharedInstance.presentNotification(notification.userInfo))
    {
        [[MCESdk sharedInstance] presentOrPerformNotification: notification.userInfo];
    }
}

@end

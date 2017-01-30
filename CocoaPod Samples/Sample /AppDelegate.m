/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

//* Manually need to comment this out for Xcode 7, can't disable with #ifdefs
@import UserNotifications;
//*/

#import "AppDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>
#import <MessageUI/MessageUI.h>
#import "MailDelegate.h"

// Action Plugins
#import "ActionMenuPlugin.h"
#import "AddToCalendarPlugin.h"
#import "AddToPassbookPlugin.h"
#import "SnoozeActionPlugin.h"
#import "DisplayWebViewPlugin.h"
#import "TextInputActionPlugin.h"

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
@end

@interface AppDelegate ()
@property NSString * string;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"action":@"set",@"standardType":@"dial", @"standardDialValue":@"\"8774266006\"", @"standardUrlValue":@"\"http://ibm.com\"", @"customType":@"sendEmail", @"customValue":@"{\"subject\":\"Hello from Sample App\", \"body\": \"This is an example email body\", \"recipient\":\"fake-email@fake-site.com\"}", @"categoryId":@"example",@"button1":@"Accept",@"button2":@"Reject"}];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if([UNUserNotificationCenter class])
    {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=MCENotificationDelegate.sharedInstance;
        NSUInteger options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay;
        [center requestAuthorizationWithOptions: options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // Enable or disable features based on authorization.
            NSLog(@"Notifications response %d, %@", granted, error);
            [application registerForRemoteNotifications];
            [center setNotificationCategories:[self appCategories]];
        }];
    }
    else
#endif
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:[self appCategories]];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
        //register to receive notifications iOS <8
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[MCEInAppManager sharedInstance] processPayload: notification.userInfo];
}

#pragma mark Register Custom Action named "sendEmail"
-(instancetype)init
{
    if(self=[super init])
    {
        [MCESdk sharedInstance].customAlertViewClass = [MyAlertView class];
        [MCESdk sharedInstance].customAlertControllerClass = [MyAlertController class];

        // MCE Inbox plugins
        [MCEInboxActionPlugin registerPlugin];
        [MCEInboxPostTemplate registerTemplate];
        [MCEInboxDefaultTemplate registerTemplate];
        
        // MCE InApp Plugins
        [MCEInAppVideoTemplate registerTemplate];
        [MCEInAppImageTemplate registerTemplate];
        [MCEInAppBannerTemplate registerTemplate];
        
        // Action Plugins
        [ActionMenuPlugin registerPlugin];
        [AddToCalendarPlugin registerPlugin];
        [AddToPassbookPlugin registerPlugin];
        [SnoozeActionPlugin registerPlugin];
        [DisplayWebViewPlugin registerPlugin];
        [TextInputActionPlugin registerPlugin];
        
        // Custom Send Email Plugin Example
        [[MCEActionRegistry sharedInstance] registerTarget:[[MailDelegate alloc] init] withSelector:@selector(sendEmail:) forAction:@"sendEmail"];
    }
    return self;
}

#pragma mark Define Static Category named "example"
- (NSSet*)appCategories {
    
    if(![UIMutableUserNotificationAction class])
        return nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if([UNNotificationCategory class])
    {
        UNNotificationAction * acceptAction = [UNNotificationAction actionWithIdentifier:@"Accept" title:@"Accept" options:UNNotificationActionOptionForeground];
        UNNotificationAction * rejectAction = [UNNotificationAction actionWithIdentifier:@"Reject" title:@"Reject" options:UNNotificationActionOptionDestructive];
        UNNotificationCategory * category = [UNNotificationCategory categoryWithIdentifier:@"example" actions:@[acceptAction, rejectAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        return [NSSet setWithObject: category];
    }
#endif
    
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
    [category setActions:@[acceptAction, rejectAction] forContext: UIUserNotificationActionContextDefault];
    [category setActions:@[acceptAction, rejectAction] forContext: UIUserNotificationActionContextMinimal];
    return [NSSet setWithObject: category];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^_Nonnull __strong)())completionHandler
{
    NSLog(@"responseInfo: %@", responseInfo);
}


#pragma mark Process Static Category No Choice Made
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(userInfo[@"aps"] && [userInfo[@"aps"][@"category"] isEqual: @"example"])
    {
        [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Static category handler" message:@"Static Category, no choice made" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark Process Static Category Choice Made
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
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
    completionHandler();
}


@end

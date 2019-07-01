/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2019
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEConfig.h"

#if __has_feature(modules)
@import UIKit;
@import UserNotifications;
#else
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#endif

/** The MCESdk class is the central integration point for the SDK as a whole. */

@interface MCESdk : NSObject

/** This property sets the current alert view class, it can be customized by the developer of the application. */
@property Class customAlertViewClass;

/** This property sets the current alert view controller class, it can be customized by the developer of the application. */
@property Class customAlertControllerClass;

/** This property can be used to override if a notification is delivered to the device when the app is running. */
@property (copy) BOOL (^presentNotification)(NSDictionary * userInfo);

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCESdk * sharedInstance NS_SWIFT_NAME(shared);

/** This method allows your app to respond to the open settings for notification request for notification quick settings **/
@property (copy) void (^openSettingsForNotification)(UNNotification * notification) API_AVAILABLE(ios(12.0));

/** @name Initialization */

/** Initialize SDK, must be called in either application delegate init or application:didFinishLaunchingWithOptions:.
 
 This method loads configuration from MceConfig.json. Either this method or handleApplicationLaunch: must be called before any other SDK method is called.
*/
- (void)handleApplicationLaunch;


/** Initialize SDK, must be called in either application delegate init or application:didFinishLaunchingWithOptions:. Either this method or handleApplicationLaunch must be called before any other SDK method is called.
 
 @param config Configuration is passed in via config dictionary instead of being loaded from MceConfig.json.
 */
- (void)handleApplicationLaunchWithConfig:(NSDictionary *)config;

/** This method should be called if the application:didFailToRegisterForRemoteNotificationsWithError: method is called if manual integration is used. */
-(void)deviceTokenRegistartionFailed;

/** Register device token with IBM Push Notification servers
 @param deviceToken from APNS registration request in application delegate application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
- (void)registerDeviceToken:(NSData *)deviceToken;

/** Manually initialize SDK, is used to wait until an event occurs before beginning to interact with the IBM servers. For example, you might not want to create a userid/channelid until after a user logs into your system. Requires  autoInitialize=FALSE MceConfig.json flag. This method may also be used if the autoReinitialize flag is set to false in the MceConfig.json file and the SDK is in the GDPR reset state.
 */
- (void) manualInitialization;

/** Manually initialize location services for SDK, requires location's autoInitialize=FALSE MceConfig.json flag. This is used to delay location services initialization until desired. */
-(void)manualLocationInitialization;

/** Shows a dynamic category notification, integration point of the application delegate application:didReceiveRemoteNotification:fetchCompletionHandler: method.

 @param userInfo passed from didReceiveRemoteNotification parameter of caller
 */
- (void)presentDynamicCategoryNotification:(NSDictionary *)userInfo;

/** Performs action defined in "notification-action" part of the payload.
 @param userInfo push payload from APNS
 */
- (void)performNotificationAction: (NSDictionary*)userInfo;

/** Process specified dynamic category notification for local notifications, integration point of the application delegate application:handleActionWithIdentifier:forLocalNotification:completionHandler:

 @param userInfo notification.userInfo of the forLocalNotification parameter of the caller
 @param identifier the identifier parameter of the caller
 */
- (void)processDynamicCategoryNotification:(NSDictionary *)userInfo identifier:(NSString*)identifier userText: (NSString*)userText;


/** Present notification to user 
 
 @param userInfo push payload from APNS

 */
-(void)presentNotification: (NSDictionary*)userInfo;

 /** Process specified dynamic category notification for remote notifications, integration point of the application delegate application:handleActionWithIdentifier:forRemoteNotification:completionHandler:
 
 @param userInfo notification.userInfo of the forLocalNotification parameter of the caller
 @param identifier the identifier parameter of the caller
 
 */
- (void)processCategoryNotification:(NSDictionary *)userInfo identifier:(NSString*)identifier;

/** Present or perform action in payload depending on the activation state of the application. If it is running before the message arrives, present the notification. If it starts as a result of a notification, execute the notification-action part of the payload.

 @param userInfo push payload from APNS
 */
-(void)presentOrPerformNotification:(NSDictionary*)userInfo;

/** Extract the message string from the APS dictionary, including string vs dictionary structure and localization and format arguments.
 
 @param aps the aps dictionary of the APNS push payload
 */
- (NSString*)extractAlert:(NSDictionary*)aps;

/** Get the current SDK Version number as a string. */
-(NSString*)sdkVersion;

/* Current configuration object, loaded when handleApplicationLaunchWithConfig: or handleApplicationLaunch execute. */
@property (nonatomic) MCEConfig* config;

/** This method walks through the view controller stack for the top view controller. */
-(UIViewController*)findCurrentViewController;

/** This property returns the current alert view class, it can be customized by the developer of the application. */
-(Class) alertViewClass;

/** This property returns the current alert view controller class, it can be customized by the developer of the application. */
-(Class) alertControllerClass;

/** This property returns true in the case that the SDK has been reset via a GDPR request but has not yet re-registered with the server. This could be due to the "autoReinitialize" flag being set to false or there is no connectivity. If the "autoReinitialize" flag is set to false and this property returns true, you could present a dialog to the user to verify that they agree to anonymous data collection and execute the manualInitialization method to re-register with the server.
 
Please note, this method is deprecated, please use MCERegistrationDetails.sharedInstance.userInvalidated instead.
 */
-(BOOL)gdprState __attribute__ ((deprecated));

@end

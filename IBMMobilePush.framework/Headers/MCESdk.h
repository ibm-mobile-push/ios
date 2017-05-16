/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "MCEConfig.h"
@import UIKit;

/** The MCESdk class is the central integration point for the SDK as a whole. */

@interface MCESdk : NSObject

/** This property sets the current alert view class, it can be customized by the developer of the application. */
@property Class customAlertViewClass;

/** This property sets the current alert view controller class, it can be customized by the developer of the application. */
@property Class customAlertControllerClass;

@property (nonatomic, assign) BOOL (^presentNotification)(NSDictionary * userInfo);

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** @name Initialization */

/** Initialize SDK, must be called in either application delegate init or application:didFinishLaunchingWithOptions:.
 
 This method loads configuration from MceConfig.plist. Either this method or handleApplicationLaunch: must be called before any other SDK method is called.
*/
- (void)handleApplicationLaunch;


/** Initialize SDK, must be called in either application delegate init or application:didFinishLaunchingWithOptions:. Either this method or handleApplicationLaunch must be called before any other SDK method is called.
 
 @param config Configuration is passed in via config dictionary instead of being loaded from MceConfig.plist.
 */
- (void)handleApplicationLaunchWithConfig:(NSDictionary *)config;


/** Register device token with IBM Push Notification servers
 @param deviceToken from APNS registration request in application delegate application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
- (void)registerDeviceToken:(NSData *)deviceToken;

/** Manually initialize SDK, is used to wait until an event occurs before beginning to interact with the IBM servers. For example, you might not want to create a userid/channelid until after a user logs into your system. Requires  autoInitialize=FALSE MceConfig.plist flag.
 */
- (void) manualInitialization;

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

@end

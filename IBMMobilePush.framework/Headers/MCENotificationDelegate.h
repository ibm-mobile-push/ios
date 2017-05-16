/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import UserNotifications;

/**
 MCENotificationDelegate provides SDK integration for the UNUserNotificationCenterDelegate methods introduced in iOS 10. 
 */
@interface MCENotificationDelegate : NSObject <UNUserNotificationCenterDelegate>

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

@end

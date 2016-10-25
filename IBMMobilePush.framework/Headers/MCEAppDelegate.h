/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import UIKit;

/** The MCEAppDelegate class is used for the simple integration method. It replaces the application delegate in main.m and forwards application delegate callbacks to the class specified in MceConfig.plist. This allows for simplified integration because you are not required to manually specify the integration points in the application delegate. */
@interface MCEAppDelegate : UIResponder <UIApplicationDelegate>

/** This is the instance of the developer's application delegate that forwards calls to the MCEAppDelegate instance. */
@property id<UIApplicationDelegate> appDelegate;
@end

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

/** The MCEAppDelegate class is used for the simple integration method. It replaces the application delegate in main.m and forwards application delegate callbacks to the class specified in MceConfig.plist. This allows for simplified integration because you are not required to manually specify the integration points in the application delegate. */
@interface MCEAppDelegate : UIResponder <UIApplicationDelegate>

/** This is the instance of the developer's application delegate that forwards calls to the MCEAppDelegate instance. */
@property (readonly) id<UIApplicationDelegate> appDelegate;
@end

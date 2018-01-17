/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#if __has_feature(modules)
@import UIKit;
@import Foundation;
#else
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

//! Project version number for IBMMobilePushWatch.
FOUNDATION_EXPORT double IBMMobilePushWatchVersionNumber;

//! Project version string for IBMMobilePushWatch.
FOUNDATION_EXPORT const unsigned char IBMMobilePushWatchVersionString[];

#import <IBMMobilePushWatch/MCEAttributesQueueManager.h>
#import <IBMMobilePushWatch/MCEConfig.h>
#import <IBMMobilePushWatch/MCEConstants.h>
#import <IBMMobilePushWatch/MCERegistrationDetails.h>
#import <IBMMobilePushWatch/MCEWatchSdk.h>
#import <IBMMobilePushWatch/MCEEventService.h>
#import <IBMMobilePushWatch/MCEEvent.h>
#import <IBMMobilePushWatch/MCENotificationDelegate.h>
#import <IBMMobilePushWatch/MCEWatchActionRegistry.h>
#import <IBMMobilePushWatch/MCENotificationInterfaceController.h>

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
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

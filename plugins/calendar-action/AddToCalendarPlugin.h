/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
@import EventKit;
@import EventKitUI;
#else
#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>

@interface AddToCalendarPlugin : NSObject <EKEventEditViewDelegate, MCEActionProtocol>
+ (instancetype)sharedInstance;
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end

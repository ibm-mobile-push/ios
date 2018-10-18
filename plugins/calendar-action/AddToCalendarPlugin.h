/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <IBMMobilePush/IBMMobilePush.h>

#if __has_feature(modules)
@import Foundation;
@import EventKit;
@import EventKitUI;
#else
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface AddToCalendarPlugin : NSObject <EKEventEditViewDelegate, MCEActionProtocol>
@property(class, nonatomic, readonly) AddToCalendarPlugin * sharedInstance NS_SWIFT_NAME(shared);
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end
NS_ASSUME_NONNULL_END

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>
#import "AddToPassbookClient.h"

NS_ASSUME_NONNULL_BEGIN
@interface AddToPassbookPlugin : NSObject <PKAddPassesViewControllerDelegate, MCEActionProtocol>
@property AddToPassbookClient * client;
@property(class, nonatomic, readonly) AddToPassbookPlugin * sharedInstance NS_SWIFT_NAME(shared);
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end
NS_ASSUME_NONNULL_END

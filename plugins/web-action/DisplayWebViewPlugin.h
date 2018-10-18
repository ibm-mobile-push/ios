/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>

NS_ASSUME_NONNULL_BEGIN
@interface DisplayWebViewPlugin : NSObject <MCEActionProtocol>
@property(class, nonatomic, readonly) DisplayWebViewPlugin * sharedInstance NS_SWIFT_NAME(shared);
-(void)performAction:(NSDictionary*)action;
+(void)registerPlugin;
@end
NS_ASSUME_NONNULL_END

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
#else
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MCEInboxActionPlugin : NSObject <MCEActionProtocol>
@property(class, nonatomic, readonly) MCEInboxActionPlugin * sharedInstance NS_SWIFT_NAME(shared);
-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload;
+(void)registerPlugin;
@end
NS_ASSUME_NONNULL_END

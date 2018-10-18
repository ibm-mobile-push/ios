/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

@import IBMMobilePush;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN
@interface CarouselAction : NSObject <MCEActionProtocol>
@property(class, nonatomic, readonly) CarouselAction * sharedInstance NS_SWIFT_NAME(shared);
-(void)performAction:(NSDictionary*)action withPayload:(NSDictionary*)payload;
+(void)registerPlugin;
@end
NS_ASSUME_NONNULL_END

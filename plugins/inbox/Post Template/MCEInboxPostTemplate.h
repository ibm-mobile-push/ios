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

#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxPostTemplate : NSObject <MCETemplate>
@property(class, nonatomic, readonly) MCEInboxPostTemplate * sharedInstance NS_SWIFT_NAME(shared);
@property NSCache * contentSizeCache;
@property NSCache * postHeightCache;
+(void)registerTemplate;
@end

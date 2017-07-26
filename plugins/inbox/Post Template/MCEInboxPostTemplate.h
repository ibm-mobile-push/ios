/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
 
#import <UIKit/UIKit.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxPostTemplate : NSObject <MCETemplate>
+ (instancetype)sharedInstance;
@property NSCache * contentSizeCache;
@property NSCache * postHeightCache;
+(void)registerTemplate;
@end

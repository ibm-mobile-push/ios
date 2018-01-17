/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <IBMMobilePush/IBMMobilePush.h>

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

@interface MCEInboxActionPlugin : NSObject

+ (instancetype)sharedInstance;
-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload;
+(void)registerPlugin;

@end

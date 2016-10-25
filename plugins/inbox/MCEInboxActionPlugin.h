/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <IBMMobilePush/IBMMobilePush.h>
#import <Foundation/Foundation.h>

@interface MCEInboxActionPlugin : NSObject

+ (instancetype)sharedInstance;
-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload;
+(void)registerPlugin;

@end

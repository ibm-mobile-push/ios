/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <Foundation/Foundation.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface SnoozeActionPlugin : NSObject <MCEActionProtocol>
+ (instancetype)sharedInstance;
-(void)performAction:(NSDictionary*)action payload:(NSDictionary*)payload;
+(void)registerPlugin;
@end

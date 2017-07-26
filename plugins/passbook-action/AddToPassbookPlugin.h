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
#import "AddToPassbookClient.h"

@interface AddToPassbookPlugin : NSObject <PKAddPassesViewControllerDelegate, MCEActionProtocol>
@property AddToPassbookClient * client;
+ (instancetype)sharedInstance;
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end

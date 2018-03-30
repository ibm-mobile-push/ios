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
@import PassKit;
#else
#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>

typedef void (^PassCallback)(PKPass * pass, NSError* error);

@interface AddToPassbookClient : MCEClient
-(void)getPassFrom: (NSURL*) url withCompletion:(PassCallback)callback;
@end



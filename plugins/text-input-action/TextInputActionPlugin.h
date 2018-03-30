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

@interface TextInputActionPlugin : NSObject <MCEActionProtocol>
+ (instancetype)sharedInstance;
-(void)performAction:(NSDictionary*)action withPayload:(NSDictionary*)payload textInput:(NSString*)textInput;
+(void)registerPlugin;
-(void) configureAlertTextField: (UITextField *) textField;

@end

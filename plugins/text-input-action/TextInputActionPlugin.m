/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "TextInputActionPlugin.h"
#import <IBMMobilePush/IBMMobilePush.h>

@implementation TextInputActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//* Implementing this method lets the SDK know you want an alert to ask for the textInput when it doesn't come through the system.
-(void) configureAlertTextField: (UITextField *) textField
{
    
}
//*/

-(void)performAction:(NSDictionary*)action withPayload:(NSDictionary*)payload textInput:(NSString*)textInput
{
    [[[MCESdk.sharedInstance.alertViewClass alloc]initWithTitle:[NSString stringWithFormat: @"User entered text %@", textInput] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:withPayload:textInput:) forAction: @"textInput"];
}

@end

/* 
 * Licensed Materials - Property of IBM 
 * 
 * 5725E28, 5725I03 
 * 
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp. 
 */

#import "InterfaceController.h"
#import <IBMMobilePushWatch/IBMMobilePushWatch.h>

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [self.versionLabel setText: MCEWatchSdk.sharedInstance.sdkVersion];
    [super awakeWithContext:context];
}

@end

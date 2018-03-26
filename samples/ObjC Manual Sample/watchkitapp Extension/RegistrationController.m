/* 
 * Licensed Materials - Property of IBM 
 * 
 * 5725E28, 5725I03 
 * 
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp. 
 */

#import "RegistrationController.h"
#import <IBMMobilePushWatch/IBMMobilePushWatch.h>

@interface  RegistrationController()
@property id observer;
@end

@implementation RegistrationController

- (void)willDisappear
{
    [super willDisappear];
    [NSNotificationCenter.defaultCenter removeObserver:self.observer];
}

- (void)willActivate
{
    [super willActivate];
    [self updateRegistrationLabels];
    self.observer = [NSNotificationCenter.defaultCenter addObserverForName:MCERegisteredNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*notification){
        [self updateRegistrationLabels];
    }];
}

-(void)updateRegistrationLabels
{
    if(MCERegistrationDetails.sharedInstance.mceRegistered)
    {
        [self.userIdLabel setText: MCERegistrationDetails.sharedInstance.userId];
        [self.channelIdLabel setText: MCERegistrationDetails.sharedInstance.channelId];
        [self.appKeyLabel setText: MCERegistrationDetails.sharedInstance.appKey];
    }
}

@end

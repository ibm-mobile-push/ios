/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
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
    self.observer = [NSNotificationCenter.defaultCenter addObserverForName:RegisteredNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*notification){
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

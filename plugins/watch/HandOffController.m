/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "HandOffController.h"

@interface HandOffController ()
@property id backgroundListener;
@end

@implementation HandOffController

- (void)awakeWithContext:(NSDictionary*)context {
    // You can customize the look and feel of the handoff from here
    // action is a NSDictionary with the context["action"] payload, you could
    // potentially display a different message depending on the type
    // of action that was handed off. Or even automatically dismiss
    // the controller after a specified amount of time.
    
    self.backgroundListener = [NSNotificationCenter.defaultCenter addObserverForName:NSExtensionHostWillResignActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [NSNotificationCenter.defaultCenter removeObserver:self.backgroundListener];
        self.backgroundListener = nil;
        [self dismissController];
    }];
    
}

-(void)willDisappear
{
    if([WKExtension.sharedExtension.visibleInterfaceController isEqual: self])
    {
        [self dismissController];
    }
    [super willDisappear];
    if(self.backgroundListener)
    {
        [NSNotificationCenter.defaultCenter removeObserver:self.backgroundListener];
        self.backgroundListener = nil;
    }
}

-(IBAction)dismiss:(id)sender
{
    [self dismissController];
}

@end

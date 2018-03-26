/* 
 * Licensed Materials - Property of IBM 
 * 
 * 5725E28, 5725I03 
 * 
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp. 
 */


#import "EventsController.h"
#import <IBMMobilePushWatch/IBMMobilePushWatch.h>

@interface EventsController()
@property NSMutableArray * listeners;
@property NSTimer * queueEventTimer;
@property NSTimer * sendEventTimer;
@property NSTimer * sendQueueTimer;
@end

@implementation EventsController

-(IBAction)sendEvent:(id)sender
{
    [self.sendEventStatus setText:@"Sending"];
    [self.sendEventStatus setTextColor:UIColor.whiteColor];
    MCEEvent * event = [[MCEEvent alloc] initWithName: @"watch" type: @"watch" timestamp:nil attributes:@{ @"immediate": @YES }];
    [[MCEEventService sharedInstance] addEvent:event immediate:TRUE];
}

-(IBAction)queueEvent:(id)sender
{
    [self.queueEventStatus setText:@"Queued"];
    [self.queueEventStatus setTextColor:UIColor.whiteColor];
    MCEEvent * event = [[MCEEvent alloc] initWithName: @"watch" type:@"watch" timestamp:nil attributes:@{ @"immediate": @NO }];
    [[MCEEventService sharedInstance] addEvent:event immediate:FALSE];
}

-(IBAction)sendQueue:(id)sender
{
    [self.sendQueueStatus setText:@"Sending"];
    [self.sendQueueStatus setTextColor:UIColor.whiteColor];
    [[MCEEventService sharedInstance] sendEvents];
}

- (void)didDeactivate
{
    [super didDeactivate];
    for (id listener in self.listeners) {
        [NSNotificationCenter.defaultCenter removeObserver:listener];
    }
}

-(void)willActivate
{
    [super willActivate];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:MCEEventSuccess object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {

        for(MCEEvent * event in note.userInfo[@"events"])
        {
            if([event.type isEqual: @"watch"] && [event.name isEqual: @"watch"])
            {
                [self.sendQueueStatus setText:@"Received"];
                [self.sendQueueStatus setTextColor:UIColor.greenColor];
                if(self.sendQueueTimer)
                {
                    [self.sendQueueTimer invalidate];
                }
                self.sendQueueTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [self.sendQueueStatus setText:@"Idle"];
                    [self.sendQueueStatus setTextColor:UIColor.lightGrayColor];
                    self.sendQueueTimer = nil;
                }];

                if([event.attributes[@"immediate"] boolValue])
                {
                    [self.sendEventStatus setText:@"Received"];
                    [self.sendEventStatus setTextColor:UIColor.greenColor];
                    if(self.sendEventTimer)
                    {
                        [self.sendEventTimer invalidate];
                    }
                    self.sendEventTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        [self.sendEventStatus setText:@"Idle"];
                        [self.sendEventStatus setTextColor:UIColor.lightGrayColor];
                        self.sendEventTimer = nil;
                    }];
                }
                else
                {
                    [self.queueEventStatus setText:@"Received"];
                    [self.queueEventStatus setTextColor:UIColor.greenColor];
                    if(self.queueEventTimer)
                    {
                        [self.queueEventTimer invalidate];
                    }
                    self.queueEventTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        [self.queueEventStatus setText:@"Idle"];
                        [self.queueEventStatus setTextColor:UIColor.lightGrayColor];
                        self.queueEventTimer = nil;
                    }];
                }
            }
        }
        
    }]];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:MCEEventFailure object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {

        for(MCEEvent * event in note.userInfo[@"events"])
        {
            if([event.type isEqual: @"watch"] && [event.name isEqual: @"watch"])
            {
                [self.sendQueueStatus setText:@"Error"];
                [self.sendQueueStatus setTextColor:UIColor.redColor];
                if(self.sendQueueTimer)
                {
                    [self.sendQueueTimer invalidate];
                }
                if([event.attributes[@"immediate"] boolValue])
                {
                    [self.sendEventStatus setText:@"Error"];
                    [self.sendEventStatus setTextColor:UIColor.redColor];
                    if(self.sendEventTimer)
                    {
                        [self.sendEventTimer invalidate];
                    }
                }
                else
                {
                    [self.queueEventStatus setText:@"Error"];
                    [self.queueEventStatus setTextColor:UIColor.redColor];
                    if(self.queueEventTimer)
                    {
                        [self.queueEventTimer invalidate];
                    }
                }
            }
        }
    }]];
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    self.listeners = [NSMutableArray array];
}

@end

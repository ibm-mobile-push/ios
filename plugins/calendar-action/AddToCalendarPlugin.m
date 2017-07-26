/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "AddToCalendarPlugin.h"
@implementation AddToCalendarPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:) forAction: @"calendar"];
}

-(void)performAction:(NSDictionary*)action
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(error)
        {
            NSLog(@"Could not add to calendar %@", [error localizedDescription]);
            return;
        }
        if(!granted)
        {
            NSLog(@"Could not get access to EventKit, can't add to calendar");
            return;
        }
        EKEvent * event = [EKEvent eventWithEventStore: store];
        event.calendar=store.defaultCalendarForNewEvents;
        if(action[@"title"])
        {
            event.title=action[@"title"];
        }
        else
        {
            NSLog(@"No title, could not add to calendar");
            return;
        }
        if(action[@"timeZone"])
        {
            event.timeZone=[NSTimeZone timeZoneWithAbbreviation: action[@"timeZone"]];
        }
        if(action[@"startDate"])
        {
            event.startDate = [MCEApiUtil iso8601ToDate: action[@"startDate"]];
        }
        else
        {
            NSLog(@"No startDate, could not add to calendar");
        }
        if(action[@"endDate"])
        {
            event.endDate = [MCEApiUtil iso8601ToDate: action[@"endDate"]];
        }
        else
        {
            NSLog(@"No endDate, could not add to calendar");
        }
        if(action[@"description"])
        {
            event.notes=action[@"description"];
        }
        
        if([action[@"interactive"] boolValue])
        {
            EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
            controller.event = event;
            controller.eventStore = store;
            controller.editViewDelegate = self;
            
            UIViewController * vc = MCESdk.sharedInstance.findCurrentViewController;
            [vc presentViewController:controller animated:TRUE completion:nil];
        }
        else
        {
            NSError * saveError = nil;
            BOOL success = [store saveEvent: event span:EKSpanThisEvent commit:TRUE error:&saveError];
            if(saveError)
            {
                NSLog(@"Could not save to calendar %@", [saveError localizedDescription]);
            }
            if(!success)
            {
                NSLog(@"Could not save to calendar");
            }
        }
        
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case  EKEventEditViewActionCanceled:
            NSLog(@"Event was not added to calendar");
            break;
        case EKEventEditViewActionSaved:
            NSLog(@"Event was added to calendar");
            break;
        case EKEventEditViewActionDeleted:
            NSLog(@"Event was deleted from calendar");
            break;
            
        default:
            break;
    }
    UIViewController * vc = MCESdk.sharedInstance.findCurrentViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end

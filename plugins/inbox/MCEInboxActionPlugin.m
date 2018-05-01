/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "MCEInboxActionPlugin.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxActionPlugin  ()
@property NSString * attribution;
@property NSString * mailingId;
@property UIViewController <MCETemplateDisplay> * displayViewController;
@end

@implementation MCEInboxActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)displayRichContent: (MCEInboxMessage*)inboxMessage
{
    inboxMessage.isRead = TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution: self.attribution mailingId: self.mailingId];
    
    self.displayViewController.inboxMessage = inboxMessage;
    [self.displayViewController setContent];
}

-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload
{
    self.attribution=nil;
    self.mailingId=nil;
    if(payload[@"mce"])
    {
        self.attribution = payload[@"mce"][@"attribution"];
        self.mailingId = payload[@"mce"][@"mailingId"];
    }
    
    if(!action[@"inboxMessageId"])
    {
        NSLog(@"Could not showInboxMessage, no inboxMessageId included %@", action);
        return;
    }
    
    NSString * template = action[@"template"];
    self.displayViewController = [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: template];
    
    if(!self.displayViewController)
    {
        NSLog(@"Could not showInboxMessage %@, %@ template not registered", action, template);
        return;
    }
    
    MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: action[@"inboxMessageId"]];
    if(inboxMessage)
    {
        [self showInboxMessage: inboxMessage];
    }
    else
    {
        [MCEInboxQueueManager.sharedInstance getInboxMessageId:action[@"inboxMessageId"] completion:^(MCEInboxMessage *inboxMessage, NSError *error) {
            if(error)
            {
                NSLog(@"Could not get inbox message from database %@", error);
                return;
            }
            [self showInboxMessage: inboxMessage];
        } ];
    }
}

-(void)showInboxMessage: (MCEInboxMessage *)inboxMessage
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showInboxMessage:) withObject:inboxMessage waitUntilDone:NO];
        return;
    }
    
    [self.displayViewController setLoading];
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];
    [self displayRichContent: inboxMessage];
}

+(void)registerPlugin
{
    [MCEActionRegistry.sharedInstance registerTarget: [self sharedInstance] withSelector:@selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}

@end

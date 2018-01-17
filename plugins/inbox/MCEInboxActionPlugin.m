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
@property NSString * richContentIdToShow;
@property NSString * inboxMessageIdToShow;
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

-(void)syncDatabase:(NSNotification*)notification
{
    MCEInboxMessage * message = nil;
    if(self.inboxMessageIdToShow)
    {
        message = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: self.inboxMessageIdToShow];
    }
    else if(self.richContentIdToShow)
    {
        message = [[MCEInboxDatabase sharedInstance] inboxMessageWithRichContentId:self.richContentIdToShow];
    }
    
    if(message)
    {
        [self.displayViewController setLoading];
        
        UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
        [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];

        [self displayRichContent: message];
        self.richContentIdToShow=nil;
        self.inboxMessageIdToShow=nil;
    }
    else
    {
        NSLog(@"Could not get inbox message from database");
    }
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
    
    self.inboxMessageIdToShow=action[@"inboxMessageId"];
    self.richContentIdToShow=action[@"value"];
    
    NSString * template = action[@"template"];
    self.displayViewController = [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: template];

    if(!self.displayViewController)
    {
        NSLog(@"Could not showInboxMessage %@, %@ template not registered", action, template);
        return;
    }
    
    [[MCEInboxQueueManager sharedInstance] syncInbox];
}

+(void)registerPlugin
{
    [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(syncDatabase:) name:@"MCESyncDatabase" object:nil];
    
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}

@end

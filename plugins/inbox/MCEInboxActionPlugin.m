/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <Foundation/Foundation.h>
#import "MCEInboxActionPlugin.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxActionPlugin  ()
@property NSString * attribution;
@property NSString * mailingId;
@property NSString * richContentIdToShow;
@property id <MCETemplateDisplay> displayViewController;
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
    if(!self.richContentIdToShow)
    {
        return;
    }
    
    MCEInboxMessage * message = [[MCEInboxDatabase sharedInstance] inboxMessageWithRichContentId:self.richContentIdToShow];
    [self displayRichContent: message];
    self.richContentIdToShow=nil;
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
    if(payload[@"mce"] && payload[@"mce"][@"attribution"])
    {
        self.attribution = payload[@"mce"][@"attribution"];
    }
    
    self.mailingId=nil;
    if(payload[@"mce"] && payload[@"mce"][@"mailingId"])
    {
        self.mailingId = payload[@"mce"][@"mailingId"];
    }
    
    NSString * richContentId = action[@"value"];
    NSString * template = action[@"template"];
    
    self.displayViewController = [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: template];
    if(!self.displayViewController)
    {
        NSLog(@"Could not showInboxMessage %@, %@ template not registered", action, template);
    }
    
    [self.displayViewController setLoading];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];
    
    self.richContentIdToShow=richContentId;
    [[MCEInboxQueueManager sharedInstance] syncInbox];
}

+(void)registerPlugin
{
    [[NSNotificationCenter defaultCenter] addObserver:[self sharedInstance] selector:@selector(syncDatabase:) name:@"MCESyncDatabase" object:nil];
    
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}

@end

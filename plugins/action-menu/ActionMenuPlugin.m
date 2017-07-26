/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "ActionMenuPlugin.h"

@implementation ActionMenuPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)showActionsMenu:(NSDictionary*)actionMenuAction withPayload:(NSDictionary*)userInfo
{
    if(!userInfo[@"category-actions"] || ![userInfo[@"category-actions"] isKindOfClass:[NSArray class]])
    {
        NSLog(@"Did not get the expected data from payload.");
        return;
    }
    
    NSString * alert = [[MCESdk sharedInstance] extractAlert:userInfo[@"aps"]];
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: appName message: alert preferredStyle: UIAlertControllerStyleAlert];
    
    int index=0;
    for (NSDictionary * action in userInfo[@"category-actions"]) {
        [alertController addAction: [UIAlertAction actionWithTitle:action[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            [[MCEActionRegistry sharedInstance] performAction: action forPayload:userInfo source:SimpleNotificationSource];
        }]];
        index++;
    }
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        // just dismiss alert
    }]];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:alertController animated:TRUE completion:nil];
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showActionsMenu:withPayload:) forAction: @"showactions"];
}

@end

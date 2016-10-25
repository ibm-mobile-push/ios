- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
{
    NSString * identifier = userActivity.userInfo[@"identifier"];
    NSDictionary * payload = userActivity.userInfo[@"payload"];
    
    [[MCESdk sharedInstance]processDynamicCategoryNotification:payload identifier:identifier userText:nil];
    
    return TRUE;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *replyInfo))reply
{
    NSString * identifier = userInfo[@"identifier"];
    NSDictionary * payload = userInfo[@"payload"];
    
    [[MCESdk sharedInstance]processDynamicCategoryNotification:payload identifier:identifier userText:nil];
    
    reply(nil);
}

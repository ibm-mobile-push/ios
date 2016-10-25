# Documentation Format
This file is in Github markdown format. See [Github page](http://bit.ly/1DCmbR3) or the markup [Ruby plugin](http://bit.ly/1La2hiA) for details.

# AppleDoc Documentation Format
Place .docset file in ~/Library/Developer/Shared/Documentation/DocSets/ to use integrated Xcode documentation

# Online Documentation
Additional documentation is available [online](http://ibm.co/1Fp0OEQ).

# Custom Actions / Plugins

## Custom Plugins
Standard actions, including url, openApp, and dial, are built into the framework, but you can register additional action types and override the built-in types by using our MCEActionRegistry system. To do this, you simply need to specify the object and selector that you wish to call when an action is fired. We recommend putting code similar to this in the initialization method of your application delegate.

```
[[MCEActionRegistry sharedInstance] registerTarget: self withSelector:@selector(viewProduct:) forAction:@"viewProduct"];
[[MCEActionRegistry sharedInstance] registerTarget: self withSelector:@selector(showCatalog:payload:) forAction:@"showCatalog"];
```

Then, you would have a method with this signature defined somewhere:

```
-(void)viewProduct:(NSDictionary*)action;
```

Or, if you need the entire payload, you could have a method with this signature defined somewhere:

```
-(void)showCatalog:(NSDictionary*)action payload:(NSDictionary*)payload;
```

## Example Plugins
We created a few example plugins that can either be used directly in your applications or used as examples of how plugins work.

### Web Action Plugin
The web action plugin overrides the url handler with code that shows the web page in a UIWebView instead of redirecting to the external Safari application as the url handler does by default. This can be integrated into your code by importing the files in plugins/web-action/* into your project and calling [WebActionPlugin registerPlugin] in your application delegate initialization method.

### Action Menu Plugin
The action menu plugin provides an additional action type called "showactions" that displays a list of actions when a notification is opened and a specific action button is not tapped. It is intended to be used in the "notification-action" portion of the payload and can be used to help guide users to make a specific choice of action when that is required. This can be integrated into your code by importing the files in plugins/action-menu/* into your project and calling [ActionMenuPlugin registerPlugin] in your application delegate initialization method.

### Rich Content Plugin
TBD

# Registration Details

## Retrieval of UserID and ChannelID
The system uses UserID and ChannelID to keep track of users and devices. Those can be retrieved from the MCERegistartionDetails class through MCERegistartionDetails.userId and MCERegistartionDetails.channelId

## Notification of Registration
You can register to be notified when registration with the Xtify servers is complete by registering for the RegisteredNotification notification like this:

```
[[NSNotificationCenter defaultCenter] addObserverForName:RegisteredNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*notification){
    // use registration information here.
}];
```

# Attributes
Both user and channel attributes are stored on the server and can be updated from your application. Channel attributes contain information about a particular device and user attributes contain information about a user of devices. The system automatically tracks the following channel attributes: osVersion, deviceModel, sdkVersion, applicationVersion and locale, but you can track any attribute you would like. These attributes are generally used for message segmentation. If you use IBM Silverpop, only user attributes are forwarded to the Silverpop servers.

You can remove all attributes stored and replace them with a new set of attributes with the "set" commands. Or you can add or update attributes using the "update" commands. You can also remove attributes using the "delete" commands. You can use the MCEAttributesClient class directly and deal with networking failures manually or you can add your changes to the MCEAttributesQueueManager class and have the SDK automatically retry when networking failures occur. Attributes can only be retrieved with the "get" commands, but because those use authentication and exposing your API Key can pose security risks, you should not do this within your application. Attribute values can be one of the following types: NSString, NSNumber or NSDate.

## Attribute Examples

### Attribute Queue Methods

#### Set User Attributes
```
[[MCEAttributesQueueManager sharedInstance] setUserAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" }];
```

#### Update User Attributes
```
[[MCEAttributesQueueManager sharedInstance] updateUserAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" }];
```

#### Delete User Attributes
```
[[MCEAttributesQueueManager sharedInstance] deleteUserAttributes: @[ @"key", @"otherKey" ]];
```

#### Set Channel Attributes
```
[[MCEAttributesQueueManager sharedInstance] setChannelAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" }];
```

#### Update Channel Attributes
```
[[MCEAttributesQueueManager sharedInstance] updateChannelAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" }];
```

#### Delete Channel Attributes
```
[[MCEAttributesQueueManager sharedInstance] deleteChannelAttributes: @[ @"key", @"otherKey" ]];
```

### Attribute Client Methods

#### Set User Attributes
```
[[MCEAttributesClient sharedInstance] setUserAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" } completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```

#### Update User Attributes
```
[[MCEAttributesClient sharedInstance] updateUserAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" } completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```

#### Delete User Attributes
```
[[MCEAttributesClient sharedInstance] deleteUserAttributes: @[ @"key", @"otherKey"] completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```

#### Set Channel Attributes
```
[[MCEAttributesClient sharedInstance] setChannelAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" } completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```


#### Update Channel Attributes
```
[[MCEAttributesClient sharedInstance] updateChannelAttributes: @{ @"key": @"value", @"otherKey": @"otherValue" } completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```

#### Delete Channel Attributes
```
[[MCEAttributesClient sharedInstance] deleteChannelAttributes: @[ @"key", @"otherKey"] completion:^(NSError * error){
    if(error)
    {
        // handle error / retry
    }
    // handle success
}];
```

# Events
Events can be sent to the Xtify servers from your app to indicate that certain transactions are taking place. Some events are automatically handled by the system including (type:name): simpleNotification:urlClicked, simpleNotification:appOpened, simpleNotification:phoneNumberClicked, application:uiPushEnabled, application:uiPushDisabled, application:sessionStart and application:sessionEnd. You can report any type or name you wish.

```
MCEEvent * event = [[MCEEvent alloc] init];
[event fromDictionary: @{ @"name":eventName, @"type":eventType, @"timestamp":[NSDate date], @"attributes": @{@"key":@"value"}}];
[[MCEEventService sharedInstance] addEvent:event immediate:FALSE];
```

When the immediate: flag is TRUE, then the event is sent right away. When it is FALSE, the event will be queued for later sending. Depending on your battery usage target, you may want to queue events to send in batches this way.

# Action Categories

## Dynamic Categories
Dynamic categories are defined by the marketer at runtime when a specialized push message is received. They create a set of action buttons dynamically, and then process the selection of those buttons dynamically using the built-in actions or your custom actions. No code needs to be written to support this behavior out-of-the-box.

## Static Categories 
Static categories are entirely defined and executed by your code. You define what categories you want to support and what actions those include as well as what happens when they are selected. 

They are defined in the application:DidFinishLaunching: method of the application delegate like this:

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIMutableUserNotificationAction* acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"Accept";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = false;
    acceptAction.authenticationRequired = false;

    UIMutableUserNotificationAction* rejectAction = [[UIMutableUserNotificationAction alloc] init];
    rejectAction.identifier = @"Reject";
    rejectAction.title = @"Reject";
    rejectAction.activationMode = UIUserNotificationActivationModeForeground;
    rejectAction.destructive = false;
    rejectAction.authenticationRequired = false;

    UIMutableUserNotificationCategory* category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = @"example";
    [category setActions:@[acceptAction, rejectAction] forContext: UIUserNotificationActionContextDefault];
    [category setActions:@[acceptAction, rejectAction] forContext: UIUserNotificationActionContextMinimal];

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories: [NSSet setWithArray: @[ category ]] ];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
        //register to receive notifications iOS <8
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}
```

Selection of those actions can be handled in the `application:handleActionWithIdentifier:forRemoteNotification:completionHandler:` method when a user makes a choice or the `application:didReceiveRemoteNotification:fetchCompletionHandler:` method when the user opens the entire notification instead of making a choice. In iOS 7 or lower, only the `application:didReceiveRemoteNotification:fetchCompletionHandler:` method will be called. This is done in your application delegate like this:

```
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(userInfo[@"aps"] && [userInfo[@"aps"][@"category"] isEqual: @"example"])
    {
        [[[UIAlertView alloc] initWithTitle:@"Static category handler" message:@"Static Category, no choice made" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if(userInfo[@"aps"] && [userInfo[@"aps"][@"category"] isEqual: @"example"])
    {
        [[[UIAlertView alloc] initWithTitle:@"Static category handler" message:[NSString stringWithFormat: @"Static Category, %@ button clicked", identifier] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]show];
    }
    completionHandler();
}
```
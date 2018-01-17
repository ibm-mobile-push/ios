/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

@objc class AppDelegate : UIResponder, UIApplicationDelegate
{
    var window: UIWindow? 
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
        UserDefaults.standard.register(defaults: ["action":"update", "standardType":"dial",  "standardDialValue":"\"8774266006\"",  "standardUrlValue":"\"http://ibm.com\"",  "customType":"sendEmail",  "customValue":"{\"subject\":\"Hello from Sample App\",  \"body\": \"This is an example email body\",  \"recipient\":\"fake-email@fake-site.com\"}",  "categoryId":"example", "button1":"Accept", "button2":"Reject"])

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate=MCENotificationDelegate.sharedInstance()
            center.requestAuthorization(options: [.alert, .sound, .carPlay, .badge], completionHandler: { (granted, error) in
                print("Notifiations response \(granted) \(String(describing: error))")
                DispatchQueue.main.sync {
                    application.registerForRemoteNotifications()
                }
                center.setNotificationCategories(self.appNotificationCategories())
            })
        }
        else if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: appCategories())
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .alert, .sound])
        }

        return true
    }
    
    override init() {
        super.init()
        
        // MCE InApp Templates Plugins
        MCEInAppVideoTemplate.register()
        MCEInAppImageTemplate.register()
        MCEInAppBannerTemplate.register()

        // MCE Action Plugins
        DisplayWebViewPlugin.register()
        ActionMenuPlugin.register()
        AddToCalendarPlugin.register()
        AddToPassbookPlugin.register()
        SnoozeActionPlugin.register()
        ExamplePlugin.register()
        
        // MCE Inbox Templates Plugins
        MCEInboxActionPlugin.register()
        MCEInboxDefaultTemplate.register()
        MCEInboxPostTemplate.register()

        // Custom Send Email Plugin
        let mail = MailDelegate();
        MCEActionRegistry.sharedInstance().registerTarget(mail, with: #selector(mail.sendEmail(action:)), forAction: "sendEmail")
        
        TextInputActionPlugin.register()
    }
    
    @available(iOS 10.0, *)
    func appNotificationCategories() -> Set<UNNotificationCategory>
    {
        let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [.destructive])
        let category = UNNotificationCategory(identifier: "example", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [.customDismissAction])
        
        return (NSSet(object: category) as? Set<UNNotificationCategory>)!;
    }
    
    @available(iOS 8.0, *)
    func appCategories() -> Set<UIUserNotificationCategory>?
    {
        let acceptAction = UIMutableUserNotificationAction.init()
        acceptAction.identifier = "Accept"
        acceptAction.title = "Accept"
        acceptAction.isDestructive=false
        acceptAction.isAuthenticationRequired=false
        
        let rejectAction = UIMutableUserNotificationAction.init()
        rejectAction.identifier = "Reject"
        rejectAction.title = "Reject"
        rejectAction.isDestructive=true
        rejectAction.isAuthenticationRequired=false
        
        let category = UIMutableUserNotificationCategory.init()
        category.identifier="example"
        category.setActions([acceptAction, rejectAction], for: .default)
        category.setActions([acceptAction, rejectAction], for: .minimal)
        return [category]
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        MCEInAppManager.sharedInstance().processPayload(notification.userInfo);
    }
    
    func isExampleCategory(userInfo: NSDictionary) -> Bool
    {
        if let aps = userInfo["aps"] as? NSDictionary
        {
            if let category = aps["category"] as? String
            {
                if category == "example"
                {
                    return true
                }
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        if isExampleCategory(userInfo: userInfo as NSDictionary)
        {
            UIAlertView.init(title: "Static category handler", message: "Static Category, no choice made", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    {
        if !isExampleCategory(userInfo: userInfo as NSDictionary)
        {
            return
        }
        
        if let aps = userInfo["aps"] as? NSDictionary
        {
            if let values = aps["category-values"] as? NSDictionary
            {
                let name = values["name"]
                let quantity = values["quantity"]
                let persist = values["persist"]
                let other = values["other"] as? NSDictionary
                if name != nil && quantity != nil && persist != nil && other != nil
                {
                    let message = other!["deniedMessage"]
                    if identifier == "Accept"
                    {
                        UIAlertView.init(title: "Static category handler", message: "User pressed \(identifier ?? "") for \(name ?? "") quantity \(quantity ?? "")", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
                        return
                    }
                    if identifier == "Reject"
                    {
                        UIAlertView.init(title: "Static category handler", message: "User pressed \(identifier ?? "") persistance \(persist ?? ""), reason \(message ?? "")", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                            .show()
                        return
                    }
                }
            }
        
            UIAlertView.init(title: "Static category handler", message: "Static Category, \(identifier ?? "") button clicked", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                .show()
            
            // Send event to Xtify Servers
            let eventName = "Name of event"
            let eventType = "Type of event"
            let attributes = NSDictionary()
            let event = MCEEvent.init()
            let attribution = aps["attribution"] as? String
            let mailingId = aps["mailingId"] as? String
            event.fromDictionary(["name":eventName, "type": eventType, "timestamp": NSDate.init(), "attributes": attributes])
            if let attrib = attribution
            {
                event.attribution = attrib
            }
            if let mailingId = mailingId
            {
                event.mailingId = mailingId
            }

            MCEEventService.sharedInstance().add(event, immediate: false)
        }
        completionHandler()
    }
}

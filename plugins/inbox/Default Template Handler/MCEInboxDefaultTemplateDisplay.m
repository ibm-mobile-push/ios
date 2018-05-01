/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxDefaultTemplateDisplay.h"
#import <IBMMobilePush/IBMMobilePush.h>

@implementation MCEInboxDefaultTemplateDisplay

-(void)syncDatabase:(NSNotification*)notification
{
    if(!self.inboxMessage)
    {
        return;
    }
    
    // May need to refresh if payload is out of sync.
    MCEInboxMessage* newInboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:self.inboxMessage.inboxMessageId];
    if(!newInboxMessage)
    {
        NSLog(@"Could not fetch inbox message %@", self.inboxMessage.inboxMessageId);
    }
    
    if([newInboxMessage isEqual: self.inboxMessage])
    {
        return;
    }
    
    [self setContent];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDatabase:) name:@"MCESyncDatabase" object:nil];
    }
    return self;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

-(IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];
}

-(void)setContent
{
    NSDictionary * messageDetails = self.inboxMessage.content[@"messageDetails"];
    NSDictionary * preview = self.inboxMessage.content[@"messagePreview"];
    
    MCEWebViewActionDelegate * actionDelegate = [MCEWebViewActionDelegate sharedInstance];
    [actionDelegate configureForSource: InboxSource inboxMessage: self.inboxMessage actions:self.inboxMessage.content[@"actions"] ];

    self.webView.delegate=actionDelegate;
    [self.webView loadHTMLString:messageDetails[@"richContent"] baseURL:nil];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    
    formatter.timeStyle = NSDateFormatterLongStyle;
    formatter.dateStyle = NSDateFormatterLongStyle;
    self.date.text = [formatter stringFromDate:self.inboxMessage.sendDate];
    
    self.subject.text=preview[@"subject"];
    
    self.boxView.hidden=FALSE;
    self.webView.hidden=FALSE;
    [self.loadingView stopAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.boxView.layer.borderWidth=1;
    self.boxView.layer.borderColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0] CGColor];

    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    CGFloat toolbarHeight = self.toolbar.frame.size.height;

    // Adjust spacing between toolbar and top when translucent toolbar or when popup
    if([self isModal])
    {
        self.topConstraint.constant = 0;
        self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
        
        UIWindow * window = UIApplication.sharedApplication.keyWindow;
        if([window respondsToSelector:@selector(safeAreaInsets)]) {
            if(window.safeAreaInsets.top > statusBarHeight) {
                self.toolbarHeightConstraint.constant = toolbarHeight + window.safeAreaInsets.top;
            } else {
                self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
            }
            
        }
    }
    else if(self.navigationController.navigationBar.translucent)
    {
        self.topConstraint.constant = statusBarHeight + toolbarHeight;
        self.toolbarHeightConstraint.constant = 0;
    }
    else
    {
        self.topConstraint = 0;
        self.toolbarHeightConstraint.constant = 0;
    }
    
    if(self.inboxMessage)
    {
        [self setContent];
        self.inboxMessage.isRead = TRUE;
    }
}

-(void)setLoading
{
    self.boxView.hidden=TRUE;
    self.webView.hidden=TRUE;
    [self.loadingView startAnimating];
}

@end

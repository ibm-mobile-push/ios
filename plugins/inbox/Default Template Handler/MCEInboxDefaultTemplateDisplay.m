/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
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
    [[MCEInboxDatabase sharedInstance] fetchInboxMessageId:self.inboxMessage.inboxMessageId completion: ^(MCEInboxMessage* newInboxMessage, NSError * error){
        if(error)
        {
            NSLog(@"Could not fetch inbox message %@", self.inboxMessage.inboxMessageId);
        }
        
        if([newInboxMessage isEqual: self.inboxMessage])
        {
            return;
        }
        
        [self setContent];
    }];
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
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)setContent
{
    NSDictionary * messageDetails = self.richContent.content[@"messageDetails"];
    NSDictionary * preview = self.richContent.content[@"messagePreview"];
    
    MCEWebViewActionDelegate * actionDelegate = [MCEWebViewActionDelegate sharedInstance];
    [actionDelegate configureForSource: InboxSource inboxMessage: self.inboxMessage richContent: self.richContent actions:self.richContent.content[@"actions"] ];

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
    for (NSLayoutConstraint * constraint in self.view.constraints)
    {
        if([constraint.firstItem isEqual:self.toolbar])
        {
            if(constraint.firstAttribute==NSLayoutAttributeTop)
            {
                if([self isModal])
                {
                    constraint.constant = statusBarHeight;
                }
                else if(self.navigationController.navigationBar.translucent)
                {
                    constraint.constant=statusBarHeight + toolbarHeight;
                }
                else
                {
                    constraint.constant = 0;
                }
            }
        }
    }
    
    // Adjust height of toolbar to hide it when non a popup
    for (NSLayoutConstraint * constraint in self.toolbar.constraints)
    {
        if(constraint.firstAttribute==NSLayoutAttributeHeight)
        {
            if([self isModal])
            {
                constraint.constant = toolbarHeight;
            }
            else
            {
                constraint.constant = 0;
            }
            
        }
    }

    if(self.richContent)
    {
        [self setContent];
    }
}

-(void)setLoading
{
    self.boxView.hidden=TRUE;
    self.webView.hidden=TRUE;
    [self.loadingView startAnimating];
}

@end

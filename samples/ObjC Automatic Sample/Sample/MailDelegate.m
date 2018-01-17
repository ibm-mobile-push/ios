/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "MailDelegate.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MailDelegate ()
@property MFMailComposeViewController * mailController;
@end

@implementation MailDelegate

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch(result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send was canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail was saved as draft");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail was sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send failed");
            break;
    }
    [controller dismissViewControllerAnimated:TRUE completion:^(){}];
}

#pragma mark Process Custom Action
-(void)sendEmail:(NSDictionary*)action
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSLog(@"Custom action with value %@", action[@"value"]);
        
        if(![MFMailComposeViewController canSendMail])
        {
            [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Cannot send mail" message:@"Please verify that you have a mail account setup." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        
        self.mailController = [[MFMailComposeViewController alloc] init];
        self.mailController.mailComposeDelegate=self;
        [self.mailController setSubject: action[@"value"][@"subject"]];
        [self.mailController setToRecipients: @[action[@"value"][@"recipient"]]];
        [self.mailController setMessageBody:action[@"value"][@"body"] isHTML:FALSE];

        UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
        [controller presentViewController:self.mailController animated:TRUE completion:^(void){}];
    });
}

@end

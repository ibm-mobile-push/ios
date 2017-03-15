/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxDefaultTemplateDisplay : UIViewController <MCETemplateDisplay>
@property IBOutlet UIWebView * webView;
@property IBOutlet UIToolbar * toolbar;
@property IBOutlet UILabel * subject;
@property IBOutlet UIView * boxView;
@property IBOutlet UILabel * date;
@property IBOutlet UIActivityIndicatorView * loadingView;
@property MCEInboxMessage * inboxMessage;
@end

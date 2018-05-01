/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
 
#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInAppBannerTemplate : UIViewController <MCEInAppTemplate>
@property IBOutlet NSLayoutConstraint * topConstraint;
@property IBOutlet NSLayoutConstraint * bottomConstraint;
@property IBOutlet UILabel * label;
@property IBOutlet UIImageView * icon;
@property IBOutlet UIImageView * close;
-(IBAction)dismiss:(id)sender;
-(IBAction)tap:(id)sender;
-(IBAction)dismissLeft:(id)sender;
-(IBAction)dismissRight:(id)sender;
@end

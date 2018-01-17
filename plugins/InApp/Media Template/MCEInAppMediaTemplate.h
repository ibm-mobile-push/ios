/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInAppMediaTemplate : UIViewController

@property IBOutlet UIButton * titleLabel;
@property IBOutlet UIButton * textLabel;
@property IBOutlet UIView * containerView;
@property IBOutlet NSLayoutConstraint * textHeightConstraint;
@property IBOutlet UIButton * contentView;
@property IBOutlet UIView * textLine;
@property IBOutlet UIActivityIndicatorView * spinner;

@property dispatch_queue_t queue;
@property bool autoDismiss;

@property MCEInAppMessage * inAppMessage;


// Only used for disabling vibrantancy selectively
@property NSLayoutConstraint * foreTextHeightConstraint;
@property UIButton * foreTitleLabel;
@property UIButton * foreTextLabel;
@property UIView * foreContainerView;


-(IBAction)dismiss: (id)sender;
-(IBAction)execute: (id)sender;
-(IBAction)expandText:(id)sender;

-(void)setTextHeight;
-(void)autoDismiss: (id)sender;
-(BOOL)isBlurAvailable;
-(void)showInAppMessage;
-(void)displayInAppMessage:(MCEInAppMessage*)message;

@end

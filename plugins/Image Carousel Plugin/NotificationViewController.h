/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>
@import SpriteKit;

@interface NotificationViewController : UIViewController
@property IBOutlet UILabel * titleLabel;
@property IBOutlet UILabel * subtitleLabel;
@property IBOutlet UILabel * bodyLabel;
@property IBOutlet SKView * skView;
@property IBOutlet UIActivityIndicatorView * activityView;
@end

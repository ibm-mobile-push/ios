/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxPostTemplateImage : UIViewController

@property IBOutlet UIImageView * contentView;
@property IBOutlet UIView * imagesView;
@property IBOutlet UIActivityIndicatorView * spinner;

@property dispatch_queue_t queue;

-(IBAction)dismiss: (id)sender;
-(BOOL)isBlurAvailable;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageUrlString: (NSString*)imageUrlString;

@end

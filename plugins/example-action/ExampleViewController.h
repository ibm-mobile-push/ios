/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>

@interface ExampleViewController : UIViewController
@property NSString *payload;
@property (nonatomic, strong) IBOutlet UILabel *payloadLabel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil payload:(NSDictionary*)payload;
-(IBAction)dismiss:(id)sender;
@end

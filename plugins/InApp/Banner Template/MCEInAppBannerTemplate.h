/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import <Foundation/Foundation.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInAppBannerTemplate : UIViewController <MCEInAppTemplate>
@property IBOutlet UILabel * label;
@property IBOutlet UIImageView * icon;
@property IBOutlet UIImageView * close;
-(IBAction)dismiss:(id)sender;
-(IBAction)tap:(id)sender;
-(IBAction)dismissLeft:(id)sender;
-(IBAction)dismissRight:(id)sender;
@end

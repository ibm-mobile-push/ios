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

@interface MCEInboxDefaultTemplateCell : UITableViewCell <MCETemplatePreview>
@property IBOutlet UILabel * subject;
@property IBOutlet UILabel * preview;
@property IBOutlet UILabel * date;
@end

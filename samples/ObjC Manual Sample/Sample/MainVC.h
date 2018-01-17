/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

@interface MainVC : UITableViewController <UIViewControllerPreviewingDelegate>
{
    IBOutlet UILabel * version;
    IBOutlet UITableViewCell * inboxCell;
    IBOutlet UITableViewCell * altInboxCell;
}
@end


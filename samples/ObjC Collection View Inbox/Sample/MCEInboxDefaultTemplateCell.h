/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxDefaultTemplateCell : UICollectionViewCell
{
    IBOutlet UILabel * label;
    IBOutlet UILabel * newLabel;
}

-(void)setInboxMessage:(MCEInboxMessage*)inboxMessage;
@end

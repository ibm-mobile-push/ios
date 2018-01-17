/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxDefaultTemplateCell.h"

@implementation MCEInboxDefaultTemplateCell

-(void)setInboxMessage:(MCEInboxMessage*)inboxMessage
{
    if(inboxMessage.isRead)
    {
        newLabel.hidden = true;
    }
    else
    {
        newLabel.hidden = false;
        newLabel.transform = CGAffineTransformMakeRotation(M_PI/4*-1);
    }
    self.layer.borderColor = UIColor.grayColor.CGColor;
    self.layer.borderWidth = 1;
    UIFont * boldFont = [UIFont boldSystemFontOfSize: UIFont.smallSystemFontSize];
    NSAttributedString * subject = [[NSAttributedString alloc] initWithString:inboxMessage.content[@"messagePreview"][@"subject"] attributes:@{ NSFontAttributeName: boldFont }];

    NSAttributedString * space = [[NSAttributedString alloc] initWithString: @" "];

    UIFont * normalFont = [UIFont systemFontOfSize: UIFont.smallSystemFontSize];
    NSAttributedString * preview = [[NSAttributedString alloc] initWithString:inboxMessage.content[@"messagePreview"][@"previewContent"] attributes:@{ NSFontAttributeName: normalFont }];

    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:subject];
    [attributedText appendAttributedString: space];
    [attributedText appendAttributedString: preview];
    label.attributedText = attributedText;
    [label sizeToFit];
}

@end

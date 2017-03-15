/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxDefaultTemplateCell.h"

@interface MCEInboxDefaultTemplateCell ()
@property NSDateFormatter * formatter;
@end

@implementation MCEInboxDefaultTemplateCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[NSLocale currentLocale]];
    self.formatter.timeStyle = NSDateFormatterNoStyle;
    self.formatter.dateStyle = NSDateFormatterShortStyle;
    [self prepareForReuse];
}

-(void)prepareForReuse
{
    self.preview.text = @"";
    self.subject.text = @"";
    self.date.text = @"";
}

-(void)setStyleForExpiredMessage:(MCEInboxMessage *)inboxMessage
{
    self.preview.alpha=0.5;
    self.subject.alpha=0.5;
    self.date.textColor = [UIColor redColor];
    self.date.text = [@"Expired: " stringByAppendingString: [self.formatter stringFromDate: inboxMessage.expirationDate]];
    [self resizeDate];
}

-(void)resizeDate
{
    // Remove existing width constraint
    NSArray * constraints = [self.date constraints];
    for (NSLayoutConstraint * constraint in constraints)
    {
        if(constraint.firstAttribute == NSLayoutAttributeWidth)
        {
            [self.date removeConstraint: constraint];
        }
    }
    
    // Add new width constraint
    CGSize size = [self.date.text sizeWithAttributes: @{NSFontAttributeName: self.date.font }];
    [self.date addConstraint:[NSLayoutConstraint constraintWithItem:self.date attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width+5]];
}

-(void)setStyleForNormalMessage:(MCEInboxMessage *)inboxMessage
{
    self.preview.alpha=1;
    self.subject.alpha=1;
    self.date.textColor = [UIColor colorWithRed:0 green:0.36 blue:1 alpha:1];
    self.date.text = [self.formatter stringFromDate: inboxMessage.sendDate];
    [self resizeDate];
}

-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage
{
    if([inboxMessage isExpired])
    {
        [self setStyleForExpiredMessage:inboxMessage];
    }
    else
    {
        [self setStyleForNormalMessage:inboxMessage];
    }
    
    
    NSDictionary * preview = inboxMessage.content[@"messagePreview"];
    
    if(inboxMessage.isRead)
    {
        self.subject.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    else
    {
        self.subject.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    }
    
    self.subject.text = preview[@"subject"];
    self.preview.text = preview[@"previewContent"];
}

@end

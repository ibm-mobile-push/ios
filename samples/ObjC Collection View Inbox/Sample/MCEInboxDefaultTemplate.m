/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxDefaultTemplate.h"
#import "MCEInboxDefaultTemplateDisplay.h"
#import "MCEInboxDefaultTemplateCell.h"

static NSString * identifier = @"defaultTemplateCell";

@implementation MCEInboxDefaultTemplate

-(BOOL)shouldDisplayInboxMessage: (MCEInboxMessage*)inboxMessage
{
    /* This would not allow the inbox to open messages that are expired */
    //if([inboxMessage isExpired])
    //    return FALSE;
    return TRUE;
}

/* This method is used to register this template with the template registry system so we can display default template messages */
+(void)registerTemplate
{
    [[MCETemplateRegistry sharedInstance] registerTemplate:@"default" hander:[[self alloc]init]];
}

/* This method will give the inbox system a view controller to display full messages in. */
-(id<MCETemplateDisplay>)displayViewController
{
    return [[MCEInboxDefaultTemplateDisplay alloc] initWithNibName:@"MCEInboxDefaultTemplateDisplay" bundle:nil];
}

+(void)setupCollectionView: (UICollectionView*)collectionView
{
    UINib * nib = [UINib nibWithNibName:@"MCEInboxDefaultTemplateCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

/* This method provides a blank table view cell that can later be customized to preview the message */
-(UICollectionViewCell *) cellForCollectionView: (UICollectionView*)collectionView inboxMessage:(MCEInboxMessage *)inboxMessage indexPath:(NSIndexPath*)indexPath
{
    MCEInboxDefaultTemplateCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setInboxMessage:inboxMessage];
    return cell;
}

@end

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <IBMMobilePush/IBMMobilePush.h>
#import "InboxVC.h"
#import "MCEInboxDefaultTemplate.h"

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end

@protocol MCECollectionTemplate
-(id<MCETemplateDisplay>)displayViewController;
-(BOOL)shouldDisplayInboxMessage: (MCEInboxMessage*)inboxMessage;
-(UICollectionViewCell *) cellForCollectionView: (UICollectionView*)collectionView inboxMessage:(MCEInboxMessage *)inboxMessage indexPath:(NSIndexPath*)indexPath;
@end

@interface InboxVC ()
@property NSMutableArray * inboxMessages;
@end

@implementation InboxVC

- (void)viewDidLoad {
    self.navigationItem.title = @"Inbox Messages";
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    float width = (self.collectionView.frame.size.width)/3;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing=0;
    [MCEInboxDefaultTemplate setupCollectionView: self.collectionView];
    self.inboxMessages = [MCEInboxDatabase.sharedInstance inboxMessagesAscending:TRUE];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.inboxMessages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCECollectionTemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    UICollectionViewCell* cell = [template cellForCollectionView: collectionView inboxMessage:inboxMessage indexPath: indexPath];
    
    if(!cell)
    {
        NSLog(@"Couldn't get a blank cell for template %@, perhaps it wasn't registered?", template);
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"oops" forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCECollectionTemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    UIViewController * vc = [self viewControllerForIndexPath:indexPath];
    [self.navigationController pushViewController:vc animated:TRUE];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

-(UIViewController*)viewControllerForIndexPath:(NSIndexPath*)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.row];
    
    NSString * template = inboxMessage.templateName;
    id <MCETemplate> templateHandler = [[MCETemplateRegistry sharedInstance] handlerForTemplate: template];
    id <MCETemplateDisplay> displayViewController = [templateHandler displayViewController];
    if(!displayViewController)
    {
        NSLog(@"%@ template requested but not registered", template);
        return nil;
    }
    
    if([templateHandler shouldDisplayInboxMessage:inboxMessage])
    {
        NSLog(@"%@ template says should display inboxMessageId %@", template, inboxMessage.inboxMessageId);
    }
    else
    {
        NSLog(@"%@ template says should not display inboxMessageId %@", template, inboxMessage.inboxMessageId);
        return nil;
    }
    
    inboxMessage.isRead=TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution:inboxMessage.attribution mailingId:inboxMessage.mailingId];
    
    [displayViewController setInboxMessage: inboxMessage];
    [displayViewController setContent];
    
    UIViewController * vc = (UIViewController *)displayViewController;
    
    UIBarButtonItem * spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem * previousButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"chevron-up"] style:UIBarButtonItemStylePlain target:self action:@selector(previousMessage:)];
    previousButton.associatedObject = indexPath;
    if(indexPath.item == 0)
        previousButton.enabled=FALSE;
    else
        previousButton.enabled=TRUE;
    
    UIBarButtonItem * nextButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"chevron-down"] style:UIBarButtonItemStylePlain target:self action:@selector(nextMessage:)];
    nextButton.associatedObject = indexPath;
    if(indexPath.item == [self.inboxMessages count]-1)
        nextButton.enabled=FALSE;
    else
        nextButton.enabled=TRUE;
    
    UIBarButtonItem * deleteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
    deleteButton.associatedObject = displayViewController;
    vc.navigationItem.rightBarButtonItems = @[deleteButton, spaceButton, nextButton, previousButton];
    
    return vc;
}


@end



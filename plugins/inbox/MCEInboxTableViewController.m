/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCEInboxTableViewController.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface MCEInboxTableViewController ()
@property NSMutableArray * inboxMessages;
@property NSMutableDictionary * richContents;
@property UIViewController * alternateDisplayViewController;
@property (nonatomic, strong) id previewingContext;
@property (nonatomic, strong) NSIndexPath *previewingIndexPath;
@end

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end

@implementation MCEInboxTableViewController

// The purpose of this method is to smoothly update the list of messages instead of just executing [self.tableView reloadData];
-(void)smartUpdateMessages:(NSMutableArray*)inboxMessages
{
    [self.tableView beginUpdates];
    NSSet * newInboxMessageSet = [NSSet setWithArray: inboxMessages];
    NSSet * inboxMessageSet = [NSSet setWithArray: self.inboxMessages];
    
    NSMutableSet * updatedInboxMessages = [newInboxMessageSet mutableCopy];
    [updatedInboxMessages intersectSet:inboxMessageSet];
    NSMutableArray * updatedIndexPaths = [NSMutableArray array];
    for(MCEInboxMessage * inboxMessage in updatedInboxMessages) {
        NSLog(@"Updated Message: %@", inboxMessage.sendDate);
        NSUInteger index = [self.inboxMessages indexOfObject: inboxMessage];
        if(index != NSNotFound) {
            MCEInboxMessage * oldInboxMessage = self.inboxMessages[index];
            if(oldInboxMessage && oldInboxMessage.isRead != inboxMessage.isRead) {
                NSLog(@"%d %d Changed Message: %@ at index %lu", oldInboxMessage.isRead, inboxMessage.isRead, inboxMessage.sendDate, (unsigned long)index);
                self.inboxMessages[index] = inboxMessage;
                [updatedIndexPaths addObject: [NSIndexPath indexPathForRow:index inSection:0]];
            }
        } else {
            NSLog(@"Couldn't find inbox message for update.");
        }
    }
    if([updatedIndexPaths count]) {
        [self.tableView reloadRowsAtIndexPaths: updatedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    NSMutableSet * deletedInboxMessages = [inboxMessageSet mutableCopy];
    [deletedInboxMessages minusSet: newInboxMessageSet];
    NSMutableArray * deletedIndexPaths = [NSMutableArray array];
    for(MCEInboxMessage * inboxMessage in deletedInboxMessages) {
        NSLog(@"Removed Message: %@", inboxMessage.sendDate);
        NSUInteger index = [self.inboxMessages indexOfObject: inboxMessage];
        if(index != NSNotFound) {
            NSLog(@"Remove row at index %lu", (unsigned long)index);
            [deletedIndexPaths addObject: [NSIndexPath indexPathForRow:index inSection:0]];
        } else {
            NSLog(@"Couldn't find inbox message for delete.");
        }
    }
    if([deletedIndexPaths count]) {
        for (NSIndexPath * indexPath in [deletedIndexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath * obj1, NSIndexPath * obj2) {
            return obj1.row > obj2.row ? NSOrderedAscending : NSOrderedDescending;
        }] ) {
            [self.inboxMessages removeObjectAtIndex: indexPath.row];
        }
        
        [self.tableView deleteRowsAtIndexPaths: deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Note, we can't use the combined update bits because the indexes added can be the same for multiple rows as it's going through
    [self.tableView endUpdates];
    
    NSMutableSet * addedInboxMessages = [newInboxMessageSet mutableCopy];
    [addedInboxMessages minusSet: inboxMessageSet];
    for(MCEInboxMessage * inboxMessage in addedInboxMessages) {
        NSLog(@"Added Message: %@", inboxMessage.sendDate);
        NSUInteger index = NSNotFound;
        for(MCEInboxMessage * oldInboxMessage in self.inboxMessages) {
            // Note, if you are ordering in ascending order, the operator below should be ">". If you are ordering in decending order, the operator below should be "<"
            if([oldInboxMessage.sendDate timeIntervalSince1970] < [inboxMessage.sendDate timeIntervalSince1970]) {
                index = [self.inboxMessages indexOfObject: oldInboxMessage];
                break;
            }
        }
        if(index == NSNotFound) {
            NSLog(@"Append message");
            [self.inboxMessages addObject: inboxMessage];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.inboxMessages.count - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            NSLog(@"Insert Message at index %lu", (unsigned long)index);
            [self.inboxMessages insertObject:inboxMessage atIndex:index];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

-(void)syncDatabase:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];

        NSMutableArray * inboxMessages = [[MCEInboxDatabase sharedInstance] inboxMessagesAscending:self.ascending];
        if(!inboxMessages)
        {
            NSLog(@"Could not sync database");
            return;
        }
        
        [self smartUpdateMessages:inboxMessages];
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MCEInboxQueueManager sharedInstance] syncInbox];
    });
}


-(void)setContentViewController: (NSNotification *) note {
    self.alternateDisplayViewController = note.object;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Notification that background server sync is complete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDatabase:) name:MCESyncDatabase object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentViewController:) name:@"setContentViewController" object:nil];
    
    // Used by user to start a background server sync
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.inboxMessages=[NSMutableArray array];
    self.richContents = [NSMutableDictionary dictionary];
    
    // Initially, grab contents of database, then start a background server sync
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:activity];
    
    NSMutableArray * inboxMessages = [[MCEInboxDatabase sharedInstance] inboxMessagesAscending: self.ascending];
    
    if(!inboxMessages)
    {
        NSLog(@"Could not fetch inbox messages");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self smartUpdateMessages:inboxMessages];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        [[MCEInboxQueueManager sharedInstance] syncInbox];
    });
    
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.row];
        inboxMessage.isDeleted=TRUE;
        [self syncDatabase:nil];
    }
}

-(void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [[MCEInboxQueueManager sharedInstance] syncInbox];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCETemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    UITableViewCell* cell = [template cellForTableView: tableView inboxMessage:inboxMessage indexPath: indexPath];
    
    if(!cell)
    {
        NSLog(@"Couldn't get a blank cell for template %@, perhaps it wasn't registered?", template);
        cell = [tableView dequeueReusableCellWithIdentifier:@"oops"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"oops"];
        }
    }
    
    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    return @[
             [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                 NSLog(@"Delete message %@", inboxMessage.inboxMessageId);
                 inboxMessage.isDeleted=TRUE;
                 
                 [self syncDatabase:nil];
             }],
             [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:inboxMessage.isRead ? @"Mark as Unread" : @"Mark as Read" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                 inboxMessage.isRead = !inboxMessage.isRead;
                 NSLog(@"Set message %@ to %@!", inboxMessage.inboxMessageId, inboxMessage.isRead ? @"Read" : @"Unread");
                 [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
             }]
             ];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tableView reloadData];
    }];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    UIViewController * vc = [self viewControllerForIndexPath:indexPath];
    
    if(self.alternateDisplayViewController)
    {
        [self.alternateDisplayViewController addChildViewController: vc];
        vc.view.frame = self.alternateDisplayViewController.view.frame;
        [self.alternateDisplayViewController.view addSubview: vc.view];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:TRUE];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(IBAction)delete:(UIBarButtonItem*)sender
{
    if(sender.associatedObject)
    {
        id <MCETemplateDisplay> templateDisplay = (id<MCETemplateDisplay>) sender.associatedObject;
        if(templateDisplay)
        {
            templateDisplay.inboxMessage.isDeleted=TRUE;
            [self.navigationController popViewControllerAnimated:TRUE];
            [self syncDatabase:nil];
        }
    }
}

-(IBAction)previousMessage:(UIBarButtonItem*)sender
{
    if(sender.associatedObject)
    {
        NSIndexPath * indexPath = (NSIndexPath *) sender.associatedObject;
        if(indexPath)
        {
            [self.navigationController popViewControllerAnimated:TRUE];
            NSIndexPath * newIndexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
            [self tableView: self.tableView didSelectRowAtIndexPath: newIndexPath];
        }
    }
    
}

-(IBAction)nextMessage:(UIBarButtonItem*)sender
{
    if(sender.associatedObject)
    {
        NSIndexPath * indexPath = (NSIndexPath *) sender.associatedObject;
        if(indexPath)
        {
            [self.navigationController popViewControllerAnimated:TRUE];
            NSIndexPath * newIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
            [self tableView: self.tableView didSelectRowAtIndexPath: newIndexPath];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath
{
    MCEInboxMessage * inboxMessage = self.inboxMessages[indexPath.item];
    id<MCETemplate> template = [[MCETemplateRegistry sharedInstance] handlerForTemplate:inboxMessage.templateName];
    return [template tableView: tableView heightForRowAtIndexPath:indexPath inboxMessage:inboxMessage];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.inboxMessages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView
{
    return 1;
}

#pragma mark Peek/Pop Support

- (BOOL)isForceTouchAvailable
{
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return NO;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    self.previewingIndexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
    
    if (self.previewingIndexPath)
    {
        UITableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:self.previewingIndexPath];
        UIViewController * vc = [self viewControllerForIndexPath:self.previewingIndexPath];
        
        if(vc)
        {
            previewingContext.sourceRect = [self.view convertRect:tableCell.frame fromView:self.tableView];
            return vc;
        }
    }
    
    return nil;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)vc
{
    if(self.alternateDisplayViewController)
    {
        [self.alternateDisplayViewController addChildViewController: vc];
        vc.view.frame = self.alternateDisplayViewController.view.frame;
        [self.alternateDisplayViewController.view addSubview: vc.view];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:TRUE];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[self.previewingIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


@end

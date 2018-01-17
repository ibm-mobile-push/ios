/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "EventsVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

typedef enum
{
    NORMAL,
    SENT,
    FAILED,
    RECIEVED,
    QUEUED
} status;

static const int EVENT_QUEUE_INDEX = 0;
static const int ADD_QUEUE_INDEX = 1;
static const int SEND_QUEUE_INDEX = 2;

@interface EventsVC ()
@property status eventQueueStatus;
@property status addQueueStatus;
@property status sendQueueStatus;

@property id queueSuccessObserver;
@property id queueFailureObserver;
@end

@implementation EventsVC

-(void)updateButtonsTo: (status)newStatus events:(NSArray*)events
{
    for(MCEEvent * event in events)
    {
        if([event.attributes[@"reference"] isEqual:@"eventQueueEvent"])
        {
            self.eventQueueStatus = newStatus;
        }
        if([event.attributes[@"reference"] isEqual:@"addQueueEvent"])
        {
            self.addQueueStatus = newStatus;
        }
    }
    
    self.sendQueueStatus = newStatus;
    [self.tableView reloadData];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.eventQueueStatus=NORMAL;
    self.addQueueStatus=NORMAL;
    self.sendQueueStatus=NORMAL;
    
    self.queueSuccessObserver = [[NSNotificationCenter defaultCenter]addObserverForName:MCEEventSuccess object:nil queue:[NSOperationQueue mainQueue] usingBlock: ^(NSNotification*note){
        [self updateButtonsTo: RECIEVED events: note.userInfo[@"events"]];
    }];
    
    self.queueFailureObserver = [[NSNotificationCenter defaultCenter]addObserverForName:MCEEventFailure object:nil queue:[NSOperationQueue mainQueue] usingBlock: ^(NSNotification*note){
        [self updateButtonsTo: FAILED events: note.userInfo[@"events"]];
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.queueSuccessObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.queueFailureObserver];
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view"];
    
    switch (indexPath.item) {
        case EVENT_QUEUE_INDEX:
            cell.textLabel.text=@"Send Event Via Queue";
            if(self.eventQueueStatus==SENT)
            {
                cell.detailTextLabel.text = @"Sending";
                self.eventQueueStatus=NORMAL;
            }
            else if(self.eventQueueStatus==RECIEVED)
            {
                cell.detailTextLabel.text = @"Received";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    self.eventQueueStatus=NORMAL;
                    [self.tableView reloadData];
                });
            }
            else if(self.eventQueueStatus==FAILED)
            {
                cell.detailTextLabel.text = @"Failed";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    self.eventQueueStatus=NORMAL;
                    [self.tableView reloadData];
                });
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            
            break;
        case ADD_QUEUE_INDEX:
            cell.textLabel.text=@"Queue an Event";
            if(self.addQueueStatus==QUEUED)
            {
                cell.detailTextLabel.text = @"Queued";
            }
            else if(self.addQueueStatus==RECIEVED)
            {
                cell.detailTextLabel.text = @"Received";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    self.addQueueStatus=NORMAL;
                    [self.tableView reloadData];
                });
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            
            break;
        case SEND_QUEUE_INDEX:
            cell.textLabel.text=@"Send Queued Events";
            if(self.sendQueueStatus==SENT)
            {
                cell.detailTextLabel.text = @"Sending";
                self.sendQueueStatus=NORMAL;
            }
            else if(self.sendQueueStatus==RECIEVED)
            {
                cell.detailTextLabel.text = @"Received";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    self.sendQueueStatus=NORMAL;
                    [self.tableView reloadData];
                });
            }
            else if(self.sendQueueStatus==FAILED)
            {
                cell.detailTextLabel.text = @"Failed";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    self.sendQueueStatus=NORMAL;
                    [self.tableView reloadData];
                });
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            
            break;
            
        default:
            break;
    }
    [cell.detailTextLabel setNeedsDisplay];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Events";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Click to send a test event, you should see the send status to the right of the click event.";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    switch (indexPath.item) {
        case EVENT_QUEUE_INDEX:
        {
            MCEEvent * event = [[MCEEvent alloc] init];
            [event fromDictionary: @{ @"name":@"appOpened", @"type":@"simpleNotification", @"timestamp":[[NSDate alloc]init], @"attributes": @{ @"reference": @"eventQueueEvent"}}];
            [[MCEEventService sharedInstance] addEvent: event immediate:TRUE];
            self.sendQueueStatus=SENT;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
        case ADD_QUEUE_INDEX:
        {
            MCEEvent * event = [[MCEEvent alloc] init];
            [event fromDictionary: @{ @"name":@"appOpened", @"type":@"simpleNotification", @"timestamp":[[NSDate alloc]init], @"attributes": @{ @"reference": @"addQueueEvent"} }];
            [[MCEEventService sharedInstance] addEvent: event immediate:FALSE];
            self.addQueueStatus=QUEUED;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
        case SEND_QUEUE_INDEX:
        {
            [[MCEEventService sharedInstance] sendEvents];
            self.sendQueueStatus=SENT;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
        default:
            break;
    }
    
}

@end

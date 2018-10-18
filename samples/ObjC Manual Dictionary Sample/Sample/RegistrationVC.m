/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "RegistrationVC.h"
#import <IBMMobilePush/IBMMobilePush.h>
#import "EditCell.h"
#import <objc/runtime.h>

@interface RegistrationVC ()
@property UITextField * orgTextField;
@property UITextField * apiTextField;
@property id observerRegistrationChanged;
@property id observerRegistration;
@property int registrationCounter;
@end

@implementation RegistrationVC

-(void)viewDidLoad
{
    self.registrationCounter = 0;
    [super viewDidLoad];
    self.observerRegistrationChanged = [[NSNotificationCenter defaultCenter] addObserverForName:MCERegistrationChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*notification){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refresh:nil];
            self.registrationCounter = self.registrationCounter + 1;
        });
    }];
    self.observerRegistration = [[NSNotificationCenter defaultCenter] addObserverForName:MCERegisteredNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*notification){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refresh:nil];
            self.registrationCounter = self.registrationCounter + 1;
        });
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerRegistrationChanged];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerRegistration];
}

-(IBAction)refresh:(id)sender
{
    [sender endRefreshing];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view" forIndexPath:indexPath];
    cell.accessibilityIdentifier = nil;
    cell.detailTextLabel.accessibilityIdentifier = nil;
    if(indexPath.item==0)
    {
        cell.textLabel.text=@"User Id";
        cell.detailTextLabel.text=MCERegistrationDetails.sharedInstance.userId;
        cell.detailTextLabel.accessibilityIdentifier = @"userId";
    }
    if(indexPath.item==1)
    {
        cell.textLabel.text=@"Channel Id";
        cell.detailTextLabel.text=MCERegistrationDetails.sharedInstance.channelId;
        cell.detailTextLabel.accessibilityIdentifier = @"channelId";
    }
    if(indexPath.item==2)
    {
        cell.textLabel.text=@"App Key";
        cell.detailTextLabel.text=MCERegistrationDetails.sharedInstance.appKey;
        cell.detailTextLabel.accessibilityIdentifier = @"appKey";
    }
    if(indexPath.item==3)
    {
        cell.accessibilityIdentifier = @"registration";
        cell.accessibilityValue = [NSString stringWithFormat: @"%d", self.registrationCounter];
        cell.textLabel.text=@"Registration";
        cell.detailTextLabel.text=MCERegistrationDetails.sharedInstance.mceRegistered ? @"Finished": @"Click to start";
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Credentials";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"User ID and Channel ID are known only after registration. The registration process could take several minutes. If you have have issues with registering a device, make sure you have the correct certificate and appKey.";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if(indexPath.item == 3)
    {
        if(!MCERegistrationDetails.sharedInstance.mceRegistered)
        {
            [MCESdk.sharedInstance manualInitialization];
        }
    }
    
}
@end



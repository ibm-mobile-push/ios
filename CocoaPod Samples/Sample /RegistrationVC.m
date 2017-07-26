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
@property id observer;
@end

@implementation RegistrationVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:RegisteredNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*notification){
        [self refresh:nil];
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

-(IBAction)refresh:(id)sender
{
    [sender endRefreshing];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0 ], [NSIndexPath indexPathForItem:1 inSection:0 ]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view" forIndexPath:indexPath];
    
    if(indexPath.item==0)
    {
        cell.textLabel.text=@"User Id";
        cell.detailTextLabel.text=MCERegistrationDetails.userId;
    }
    if(indexPath.item==1)
    {
        cell.textLabel.text=@"Channel Id";
        cell.detailTextLabel.text=MCERegistrationDetails.channelId;
    }
    if(indexPath.item==2)
    {
        MCEConfig * config = [[MCESdk sharedInstance] config];
        cell.textLabel.text=@"App Key";
        cell.detailTextLabel.text=config.appKey;
    }
    
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
    if(indexPath.item==3)
        [self.orgTextField becomeFirstResponder];
    else if(indexPath.item==4)
        [self.apiTextField becomeFirstResponder];
    else
    {
        [self.orgTextField resignFirstResponder];
        [self.apiTextField resignFirstResponder];
    }
}
@end

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "iBeaconVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface iBeaconVC ()
@property NSArray * beaconRegions;
@property NSMutableDictionary * beaconStatus;
@property CLLocationManager * locationManager;
@end

@implementation iBeaconVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;

    self.beaconRegions = [[[MCELocationDatabase sharedInstance] beaconRegions] sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"major" ascending: TRUE]]];
    self.beaconStatus = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserverForName:EnteredBeacon object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconStatus[note.userInfo[@"major"]] = [NSString stringWithFormat: @"Entered Minor %@", note.userInfo[@"minor"]];
        [self.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:ExitedBeacon object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconStatus[note.userInfo[@"major"]] = [NSString stringWithFormat: @"Exited Minor %@", note.userInfo[@"minor"]];
        [self.tableView reloadData];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:LocationDatabaseUpdated object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconRegions = [[[MCELocationDatabase sharedInstance] beaconRegions] sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"major" ascending: TRUE]]];
        [self.tableView reloadData];
    }];
}

-(IBAction)refresh:(id)sender
{
    [[[MCELocationClient alloc] init] scheduleSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.item == 1)
    {
        [MCESdk.sharedInstance manualLocationInitialization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell * vertical = [tableView dequeueReusableCellWithIdentifier:@"vertical" forIndexPath:indexPath];
        MCEConfig* config = [[MCESdk sharedInstance] config];
        
        if(indexPath.item==0)
        {
            vertical.textLabel.text = @"UUID";
            NSString * uuid = [config.beaconUUID UUIDString];
            if(uuid)
            {
                vertical.detailTextLabel.text = uuid;
                vertical.detailTextLabel.textColor=[UIColor blackColor];
            }
            else
            {
                vertical.detailTextLabel.text = @"UNDEFINED";
                vertical.detailTextLabel.textColor=[UIColor grayColor];
            }
        }
        else
        {
            vertical.textLabel.text = @"Status";
            if(config.beaconEnabled)
            {
                switch(CLLocationManager.authorizationStatus)
                {
                    case kCLAuthorizationStatusDenied:
                        vertical.detailTextLabel.text = @"DENIED";
                        vertical.detailTextLabel.textColor = [UIColor redColor];
                        break;
                    case kCLAuthorizationStatusNotDetermined:
                        vertical.detailTextLabel.text = @"DELAYED (Touch to enable)";
                        vertical.detailTextLabel.textColor = [UIColor grayColor];

                        break;
                    case kCLAuthorizationStatusAuthorizedAlways:
                        vertical.detailTextLabel.text = @"ENABLED";
                        vertical.detailTextLabel.textColor=[UIColor greenColor];
                        break;
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                        vertical.detailTextLabel.text = @"ENABLED WHEN IN USE";
                        vertical.detailTextLabel.textColor=[UIColor grayColor];
                        break;
                    case kCLAuthorizationStatusRestricted:
                        vertical.detailTextLabel.text = @"RESTRICTED?";
                        vertical.detailTextLabel.textColor = [UIColor grayColor];
                        break;
                }
            }
            else
            {
                vertical.detailTextLabel.text = @"DISABLED";
                vertical.detailTextLabel.textColor=[UIColor redColor];
            }
        }
        return vertical;
    }

    UITableViewCell * basic = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];

    NSNumber * major = [self.beaconRegions[indexPath.item] major];
    basic.textLabel.text = [NSString stringWithFormat: @"%@", major];
    if(self.beaconStatus[major])
        basic.detailTextLabel.text = self.beaconStatus[major];
    else
        basic.detailTextLabel.text = @"";

    return basic;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 2;
    return self.beaconRegions.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"iBeacon Feature";
    return @"iBeacon Major Regions";
}
@end

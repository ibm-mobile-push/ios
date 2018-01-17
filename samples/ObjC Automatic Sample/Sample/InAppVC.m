/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "InAppVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

#define BOTTOM_BANNER_ITEM 0
#define TOP_BANNER_ITEM 1
#define IMAGE_ITEM 2
#define VIDEO_ITEM 3
#define NEXT_ITEM 4

#define BACKGROUND_SECTION 0
#define EXECUTE_SECTION 1
#define CANNED_SECTION 2

@interface InAppVC ()

@end

@implementation InAppVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return 50;
    return 34;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView: tableView heightForHeaderInSection:section];
    UIView * view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(10, height - 16 - 3, tableView.frame.size.width-20, 16)];
    [view addSubview: label];
    if(tableView.layer.contents)
    {
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:13];
    }
    else
    {
        view.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:13];
    }
    
    switch (section)
    {
        case BACKGROUND_SECTION:
        {
            label.text = @"Toggle Background";
            break;
        }
        case EXECUTE_SECTION:
        {
            label.text = @"Execute InApp";
            break;
        }
        case CANNED_SECTION:
        {
            label.text = @"Add Canned InApp";
            break;
        }
    }
    label.text = [label.text uppercaseString];
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(tableView.layer.contents)
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor=[UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor=[UIColor blackColor];
    }
    switch(indexPath.section)
    {
        case BACKGROUND_SECTION:
        {
            cell.textLabel.text=@"Toggle background image";
            break;
        }
        default:
        {
            switch (indexPath.item) {
                case TOP_BANNER_ITEM:
                {
                    cell.textLabel.text = @"Top Banner Template";
                    break;
                }
                case BOTTOM_BANNER_ITEM:
                {
                    cell.textLabel.text = @"Bottom Banner Template";
                    break;
                }
                case IMAGE_ITEM:
                {
                    cell.textLabel.text = @"Image Template";
                    break;
                }
                case VIDEO_ITEM:
                {
                    cell.textLabel.text = @"Video Template";
                    break;
                }
                case NEXT_ITEM:
                {
                    cell.textLabel.text = @"Next Queued Template";
                    break;
                }
            }
        }
    }
    return cell;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayVideo:) forAction:@"showVideo"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayTopBanner:) forAction:@"showTopBanner"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayBottomBanner:) forAction:@"showBottomBanner"];
    [[MCEActionRegistry sharedInstance] registerTarget:self withSelector:@selector(displayImage:) forAction:@"showImage"];
}

-(void)displayBottomBanner:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"bottomBanner"]];
}

-(void)displayTopBanner:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"topBanner"]];
}

-(void)displayNext:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"all"]];
}

-(void)displayImage:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"image"]];
}

-(void)displayVideo:(NSDictionary*)userInfo
{
    [[MCEInAppManager sharedInstance] executeRule:@[@"video"]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case BACKGROUND_SECTION:
        {
            return 1;
            break;
        }
        case EXECUTE_SECTION:
        {
            return 5;
            break;
        }
        case CANNED_SECTION:
        {
            return 4;
            break;
        }
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    switch (indexPath.section) {
        case BACKGROUND_SECTION:
        {
            tableView.layer.contents = (__bridge id _Nullable)(tableView.layer.contents ? nil : [UIImage imageNamed:@"background.jpg"].CGImage);
            tableView.layer.contentsGravity = kCAGravityResizeAspectFill;
            [tableView reloadData];
            break;
        }
        case EXECUTE_SECTION:
        {
            switch (indexPath.item) {
                case TOP_BANNER_ITEM:
                {
                    [self displayTopBanner: nil];
                    break;
                }
                case BOTTOM_BANNER_ITEM:
                {
                    [self displayBottomBanner: nil];
                    break;
                }
                case IMAGE_ITEM:
                {
                    [self displayImage: nil];
                    break;
                }
                case VIDEO_ITEM:
                {
                    [self displayVideo: nil];
                    break;
                }
                case NEXT_ITEM:
                {
                    [self displayNext: nil];
                    break;
                }
            }
            
            break;
        }
            
        case CANNED_SECTION:
        {
            NSDictionary * userInfo;
            NSString * body;
            
            switch (indexPath.item) {
                case TOP_BANNER_ITEM:
                {
                    body = @"Added Five InApp Banner Template Messages";
                    userInfo = @{@"aps":@{@"alert": body},
                                      @"notification-action": @{@"type": @"showTopBanner"},
                                      @"inApp": @{
                                              @"rules": @[@"topBanner", @"all"],
                                              @"maxViews": @5,
                                              @"template": @"default",
                                              @"content": @{
                                                      @"orientation":@"top",
                                                      @"action": @{@"type":@"url", @"value": @"http://ibm.co"},
                                                      @"text":@"Canned Banner Template Text",
                                                      @"icon": @"note",
                                                      @"color": @"0077FF"
                                                      },
                                              @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                              @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                              },
                                      };
                    break;
                }
                case BOTTOM_BANNER_ITEM:
                {
                    body = @"Added Five InApp Banner Template Messages";
                    userInfo = @{@"aps":@{@"alert": body},
                                      @"notification-action": @{@"type": @"showBottomBanner"},
                                      @"inApp": @{
                                              @"rules": @[@"bottomBanner", @"all"],
                                              @"maxViews": @5,
                                              @"template": @"default",
                                              @"content": @{
                                                      @"action": @{@"type":@"url", @"value": @"http://ibm.co"},
                                                      @"text":@"Canned Banner Template Text",
                                                      @"icon": @"note",
                                                      @"color": @"0077FF"
                                                      },
                                              @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                              @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                              },
                                      };
                    break;
                }
                case IMAGE_ITEM:
                {
                    body = @"Added Five InApp Image Template Messages";
                    userInfo = @{@"aps":@{@"alert": body},
                                      @"notification-action": @{@"type": @"showImage"},
                                      @"inApp": @{
                                              @"rules": @[@"image", @"all"],
                                              @"maxViews": @5,
                                              @"template": @"image",
                                              @"content": @{
                                                      @"action": @{@"type":@"url", @"value": @"http://ibm.co"},
                                                      @"title":@"Canned Image Template Title",
                                                      @"text":@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt. ",
                                                      @"image": @"https://www.ibm.com/us-en/images/homepage/leadspace/01172016_ls_dynamic-pricing-announcement_bg_14018_2732x1300.jpg"
                                                      }
                                              },
                                      @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                      @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                      };
                    break;
                }
                case VIDEO_ITEM:
                {
                    body = @"Added Five InApp Video Template Messages";
                    userInfo = @{@"aps":@{@"alert": body},
                                      @"notification-action": @{@"type": @"showVideo"},
                                      @"inApp": @{
                                              @"rules": @[@"video", @"all"],
                                              @"maxViews": @5,
                                              @"template": @"video",
                                              @"content": @{
                                                      @"action": @{@"type":@"url", @"value": @"http://ibm.co"},
                                                      @"title":@"Canned Video Template Title",
                                                      @"text":@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt. ",
                                                      @"video":@"http://techslides.com/demos/sample-videos/small.mp4"
                                                      }
                                              },
                                      @"triggerDate": [MCEApiUtil dateToIso8601Format: [NSDate distantPast] ],
                                      @"expirationDate": [MCEApiUtil dateToIso8601Format: [NSDate distantFuture] ],
                                      };
                    break;
                }
            }
            
            if([UNMutableNotificationContent class])
            {
                UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                content.body = body;
                content.sound = [UNNotificationSound defaultSound];
                content.userInfo = userInfo;
                
                UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
                UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"note" content:content trigger:trigger];
                
                // Schedule the notification.
                UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if(error)
                    {
                        NSLog(@"Could not send local notification %@", error.localizedDescription);
                        return;
                    }
                    NSLog(@"Local notification sent");
                }];
            }
            else
            {
                UILocalNotification * localNote = [[UILocalNotification alloc] init];
                localNote.alertBody = body;
                localNote.soundName = UILocalNotificationDefaultSoundName;
                localNote.userInfo = userInfo;
                [[UIApplication sharedApplication] presentLocalNotificationNow: localNote];
            }
            
            break;
        }
    }
    
}

@end

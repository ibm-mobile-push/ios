/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2015
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "AttributesVC.h"
#import "EditCell.h"
#import <objc/runtime.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface AttributesVC ()
@property BOOL flashSent;
@property BOOL flashReceived;
@property BOOL flashFailure;
@property BOOL flashQueueSent;
@property BOOL flashQueueReceived;
@property BOOL flashQueueFailure;
@property UITextField * nameField;
@property UITextField * valueField;
@property UISegmentedControl * actionField;
@property MCEAttributesClient * client;
@property MCEAttributesQueueManager * queue;
@end

@implementation AttributesVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.client = [[MCEAttributesClient alloc] init];
    self.queue = [[MCEAttributesQueueManager alloc] init];
    self.flashSent=FALSE;
    self.flashReceived=FALSE;
    self.flashFailure=FALSE;
    self.flashQueueSent=FALSE;
    self.flashQueueReceived=FALSE;
    self.flashQueueFailure=FALSE;
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:SetUserAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:SetUserAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:UpdateUserAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:UpdateUserAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:DeleteUserAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:DeleteUserAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:SetChannelAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:SetChannelAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:UpdateChannelAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:UpdateChannelAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:DeleteChannelAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:DeleteChannelAttributesError object:nil];
}
-(void)dealloc
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name: SetUserAttributesSuccess object:nil];
    [center removeObserver:self name: SetUserAttributesError object:nil];
    [center removeObserver:self name: UpdateUserAttributesSuccess object:nil];
    [center removeObserver:self name: UpdateUserAttributesError object:nil];
    [center removeObserver:self name: DeleteUserAttributesSuccess object:nil];
    [center removeObserver:self name: DeleteUserAttributesError object:nil];
    [center removeObserver:self name: SetChannelAttributesSuccess object:nil];
    [center removeObserver:self name: SetChannelAttributesError object:nil];
    [center removeObserver:self name: UpdateChannelAttributesSuccess object:nil];
    [center removeObserver:self name: UpdateChannelAttributesError object:nil];
    [center removeObserver:self name: DeleteChannelAttributesSuccess object:nil];
    [center removeObserver:self name: DeleteChannelAttributesError object:nil];
}

-(void)attributesQueueSuccess:(NSNotification*)notification
{
    self.flashQueueReceived=TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:4 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
}

-(void)attributesQueueError:(NSNotification*)notification
{
    self.flashQueueFailure=TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:4 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    return;
}

-(void)changeSelect:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(self.actionField.selectedSegmentIndex==0)
    {
        [defaults setObject:@"set" forKey:@"action"];
    }
    else if(self.actionField.selectedSegmentIndex==1)
    {
        [defaults setObject:@"update" forKey:@"action"];
    }
    else if(self.actionField.selectedSegmentIndex==2)
    {
        [defaults setObject:@"delete" forKey:@"action"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.item==3 || indexPath.item==4)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view"];
        
        if(indexPath.item==3)
        {
            cell.textLabel.text = @"Click to send";
            if(self.flashReceived)
            {
                cell.detailTextLabel.text = @"Received";
                self.flashReceived=FALSE;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
            else if(self.flashSent)
            {
                cell.detailTextLabel.text = @"Sending (60 second timeout)";
                self.flashSent=FALSE;
            }
            else if(self.flashFailure)
            {
                cell.detailTextLabel.text = @"Failed";
                self.flashFailure=FALSE;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
        }
        else
        {
            cell.textLabel.text = @"Click to send via queue";
            if(self.flashQueueReceived)
            {
                cell.detailTextLabel.text = @"Received";
                self.flashQueueReceived=FALSE;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
            else if(self.flashQueueSent)
            {
                cell.detailTextLabel.text = @"Sending (60 second timeout)";
                self.flashQueueSent=FALSE;
            }
            else if(self.flashQueueFailure)
            {
                cell.detailTextLabel.text = @"Failed";
                self.flashQueueFailure=FALSE;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
        }
        
        [cell.detailTextLabel setNeedsDisplay];
        return cell;
    }
    
    EditCell * cell = nil;
    
    NSString * action = [defaults stringForKey:@"action"];
    if(indexPath.item==2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"select"];
        cell.textField.text=@"Choose an Action";
        UISegmentedControl * detail = cell.selectField;
        [detail addTarget:self action:@selector(changeSelect:) forControlEvents:UIControlEventValueChanged];
        
        if([action isEqual:@"set"])
            detail.selectedSegmentIndex=0;
        else if([action isEqual:@"update"])
            detail.selectedSegmentIndex=1;
        else if([action isEqual:@"delete"])
            detail.selectedSegmentIndex=2;
        self.actionField=detail;
    }
    else
    {
        NSString * key = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"edit"];
        UITextField * detail = cell.editField;
        detail.delegate=self;
        if(indexPath.item==0)
        {
            cell.textField.text=@"Enter your attribute";
            self.nameField=detail;
            key=@"attributeName";
        }
        else if(indexPath.item==1)
        {
            cell.textField.text=@"Enter your value";
            self.valueField=detail;
            key=@"attributeValue";
            if([action isEqual:@"delete"])
                cell.textField.textColor=[UIColor grayColor];
            else
                cell.textField.textColor=[UIColor blackColor];
        }
        objc_setAssociatedObject(detail, @"key", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        detail.text = [defaults stringForKey:key];
    }
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Send User Attributes";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item==2)
        return 68;
    return 44;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if(indexPath.item==0)
        [self.nameField becomeFirstResponder];
    else if(indexPath.item==1)
        [self.valueField becomeFirstResponder];
    else
    {
        [self.nameField resignFirstResponder];
        [self.valueField resignFirstResponder];
    }
    
    if(indexPath.item==3 || indexPath.item==4)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * action = [defaults stringForKey:@"action"];
        NSString * attributeName = [defaults stringForKey:@"attributeName"];
        NSString * attributeValue = [defaults stringForKey:@"attributeValue"];
        if(!attributeName || !attributeValue)
        {
            [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Please enter values" message:@"Please enter names and values before pressing the send button" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            return;
        }
        
        if(indexPath.item==3)
        {
            void (^completion)(NSError*) = ^(NSError * error) {
                if(error)
                {
                    self.flashFailure=TRUE;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                    return;
                }
                
                self.flashReceived=TRUE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            };
            
            if([action isEqual:@"delete"])
            {
                [self.client deleteUserAttributes: @[attributeName] completion: completion];
            }
            if([action isEqual:@"update"])
            {
                [self.client updateUserAttributes: @{attributeName:attributeValue} completion: completion];
            }
            if([action isEqual:@"set"])
            {
                [self.client setUserAttributes: @{attributeName:attributeValue} completion:completion];
            }
            self.flashSent=TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
        if(indexPath.item==4)
        {
            if([action isEqual:@"delete"])
            {
                [self.queue deleteUserAttributes: @[attributeName]];
            }
            if([action isEqual:@"update"])
            {
                [self.queue updateUserAttributes: @{attributeName:attributeValue}];
            }
            if([action isEqual:@"set"])
            {
                [self.queue setUserAttributes: @{attributeName:attributeValue}];
            }
            self.flashQueueSent=TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }
    }
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString * key = objc_getAssociatedObject(textField, @"key");
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:key];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

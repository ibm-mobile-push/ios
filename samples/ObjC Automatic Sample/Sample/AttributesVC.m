/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
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
@property MCEAttributesQueueManager * queue;
@end

static const int UPDATE_INDEX = 0;
static const int DELETE_INDEX = 1;

static const int ENTER_NAME_INDEX = 0;
static const int ENTER_VALUE_INDEX = 1;
static const int CHOOSE_ACTION_INDEX = 2;
static const int SEND_VIA_QUEUE_INDEX = 3;

@implementation AttributesVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.queue = [[MCEAttributesQueueManager alloc] init];
    self.flashSent=FALSE;
    self.flashReceived=FALSE;
    self.flashFailure=FALSE;
    self.flashQueueSent=FALSE;
    self.flashQueueReceived=FALSE;
    self.flashQueueFailure=FALSE;
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:UpdateUserAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:UpdateUserAttributesError object:nil];
    [center addObserver:self selector:@selector(attributesQueueSuccess:) name:DeleteUserAttributesSuccess object:nil];
    [center addObserver:self selector:@selector(attributesQueueError:) name:DeleteUserAttributesError object:nil];
}
-(void)dealloc
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name: UpdateUserAttributesSuccess object:nil];
    [center removeObserver:self name: UpdateUserAttributesError object:nil];
    [center removeObserver:self name: DeleteUserAttributesSuccess object:nil];
    [center removeObserver:self name: DeleteUserAttributesError object:nil];
}

-(void)attributesQueueSuccess:(NSNotification*)notification
{
    self.flashQueueReceived=TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:SEND_VIA_QUEUE_INDEX inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    
}

-(void)attributesQueueError:(NSNotification*)notification
{
    self.flashQueueFailure=TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:SEND_VIA_QUEUE_INDEX inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
    return;
}

-(void)changeSelect:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(self.actionField.selectedSegmentIndex==UPDATE_INDEX)
    {
        [defaults setObject:@"update" forKey:@"action"];
    }
    else if(self.actionField.selectedSegmentIndex==DELETE_INDEX)
    {
        [defaults setObject:@"delete" forKey:@"action"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:ENTER_VALUE_INDEX inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.item==SEND_VIA_QUEUE_INDEX)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view"];
        
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
        
        [cell.detailTextLabel setNeedsDisplay];
        return cell;
    }
    
    EditCell * cell = nil;
    
    NSString * action = [defaults stringForKey:@"action"];
    if(indexPath.item==CHOOSE_ACTION_INDEX)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"select"];
        cell.textField.text=@"Choose an Action";
        UISegmentedControl * detail = cell.selectField;
        [detail addTarget:self action:@selector(changeSelect:) forControlEvents:UIControlEventValueChanged];
        
        if([action isEqual:@"update"])
            detail.selectedSegmentIndex=UPDATE_INDEX;
        else if([action isEqual:@"delete"])
            detail.selectedSegmentIndex=DELETE_INDEX;
        self.actionField=detail;
    }
    else
    {
        NSString * key = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"edit"];
        UITextField * detail = cell.editField;
        detail.delegate=self;
        if(indexPath.item==ENTER_NAME_INDEX)
        {
            cell.textField.text=@"Enter your attribute";
            self.nameField=detail;
            key=@"attributeName";
        }
        else if(indexPath.item==ENTER_VALUE_INDEX)
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
    return 4;
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
    if(indexPath.item==CHOOSE_ACTION_INDEX)
        return 68;
    return 44;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if(indexPath.item==ENTER_NAME_INDEX)
        [self.nameField becomeFirstResponder];
    else if(indexPath.item==ENTER_VALUE_INDEX)
        [self.valueField becomeFirstResponder];
    else
    {
        [self.nameField resignFirstResponder];
        [self.valueField resignFirstResponder];
    }
    
    if(indexPath.item==SEND_VIA_QUEUE_INDEX)
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
        
        if(indexPath.item==SEND_VIA_QUEUE_INDEX)
        {
            if([action isEqual:@"delete"])
            {
                [self.queue deleteUserAttributes: @[attributeName]];
            }
            if([action isEqual:@"update"])
            {
                [self.queue updateUserAttributes: @{attributeName:attributeValue}];
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

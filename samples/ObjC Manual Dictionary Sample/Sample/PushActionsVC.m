/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#import "PushActionsVC.h"
#import "EditCell.h"
#import <IBMMobilePush/IBMMobilePush.h>
#import <objc/runtime.h>

@interface PushActionsVC ()
@property UIColor * standardTextColor;
@property UITextField * standardValue;
@property UITextField * customType;
@property UITextField * customValue;
@property id observer;
@end

@implementation PushActionsVC

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.item==0 && indexPath.section==0)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"view" forIndexPath:indexPath];
        cell.textLabel.text=@"Type";
        cell.detailTextLabel.text=[defaults stringForKey:@"standardType"];
        return cell;
    }
    else if(indexPath.item==0 || indexPath.item==1)
    {
        EditCell * cell = [tableView dequeueReusableCellWithIdentifier:@"edit"];
        UITextField * detail = cell.editField;
        detail.delegate=self;
        NSString * key = nil;
        if(indexPath.item==0)
        {
            cell.textField.text=@"Type";
            key = @"customType";
            self.customType = detail;
        }
        else if(indexPath.item==1)
        {
            cell.textField.text=@"Value";
            if(indexPath.section==0)
            {
                NSString * type = [defaults valueForKey:@"standardType"];
                if([type isEqual:@"url"])
                    key = @"standardUrlValue";
                else if([type isEqual:@"dial"])
                    key = @"standardDialValue";
                self.standardValue = detail;
            }
            else
            {
                key = @"customValue";
                self.customValue = detail;
            }
        }
        if(key)
        {
            detail.text = [defaults stringForKey:key];
            detail.enabled=TRUE;
        }
        else
        {
            detail.text=@"";
            detail.enabled=FALSE;
        }
        objc_setAssociatedObject(detail, @"key", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(detail, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return cell;
    }
    else if(indexPath.item==2)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"longview" forIndexPath:indexPath];
        cell.textLabel.text=@"JSON";
        NSString * type=nil;
        NSString * value = nil;
        if(indexPath.section==0)
        {
            type=[defaults stringForKey:@"standardType"];

            if([[defaults valueForKey:@"standardType"] isEqual:@"url"])
                value = [defaults stringForKey:@"standardUrlValue"];
            if([[defaults valueForKey:@"standardType"] isEqual:@"dial"])
                value = [defaults stringForKey:@"standardDialValue"];
        }
        else
        {
            type = [defaults stringForKey:@"customType"];
            value = [defaults stringForKey:@"customValue"];
        }
        
        if(value)
        {
            NSData * valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSError * error = nil;
            value = [NSJSONSerialization JSONObjectWithData:valueData options:NSJSONReadingAllowFragments error:&error];
            if(error)
            {
                [[[MCESdk.sharedInstance.alertViewClass alloc] initWithTitle:@"Value entry invalid" message:@"Could not serialize json. Is it valid?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            }
        }
        
        NSDictionary * jsonDict = value ? @{@"type": type, @"value": value} : @{@"type": type};
        
        NSError * jsonError = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
        cell.detailTextLabel.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];        return cell;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"Standard Action";
    return @"Custom Action";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section==0)
        return @"The action opens a dialer to call the number that is specified in the \"value\" key";
    return @"Please look at the application code for the implementation of custom actions (customAction). You can use that code as a starting point to create more custom actions. For more details, please see http://ibm.co/1Fp0OEQ";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    if(indexPath.item==1 && indexPath.section==0)
    {
        [self.standardValue becomeFirstResponder];
    }
    else if(indexPath.item==0 && indexPath.section==1)
    {
        [self.customType becomeFirstResponder];
    }
    else if(indexPath.item==1 && indexPath.section==1)
    {
        [self.customValue becomeFirstResponder];
    }
    else
    {
        [self.standardValue resignFirstResponder];
        [self.customType resignFirstResponder];
        [self.customValue resignFirstResponder];
    }
    
    if(indexPath.item==0 && indexPath.section==0)
    {
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Select Standard Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"dial", @"url", @"openApp", nil];
        objc_setAssociatedObject(sheet, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [sheet showInView: self.tableView];
    }
}
#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString * key = objc_getAssociatedObject(textField, @"key");
    NSIndexPath * indexPath = objc_getAssociatedObject(textField, @"indexPath");
    NSIndexPath * jsonIndexPath = [NSIndexPath indexPathForItem:2 inSection:indexPath.section];
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:key];
    [self.tableView reloadRowsAtIndexPaths:@[jsonIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
        [[NSUserDefaults standardUserDefaults] setObject:@"dial" forKey:@"standardType"];
    if(buttonIndex==1)
        [[NSUserDefaults standardUserDefaults] setObject:@"url" forKey:@"standardType"];
    if(buttonIndex==2)
        [[NSUserDefaults standardUserDefaults] setObject:@"openApp" forKey:@"standardType"];

    NSIndexPath * indexPath = objc_getAssociatedObject(actionSheet, @"indexPath");
    NSIndexPath * jsonIndexPath = [NSIndexPath indexPathForItem:2 inSection:indexPath.section];
    NSIndexPath * valueIndexPath = [NSIndexPath indexPathForItem:1 inSection:indexPath.section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath, jsonIndexPath, valueIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end

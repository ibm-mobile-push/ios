/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "AttributesVC.h"
#import "EditCell.h"
#import <objc/runtime.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface AttributesVC () {
    UIColor * errorColor;
    UIColor * successColor;
    UIColor * queuedColor;
    UIDatePicker * datePicker;
    NSDateFormatter * dateFormatter;
    UIToolbar * keyboardDoneButtonView;
    NSNumberFormatter * numberFormatter;
}
    @end

@implementation AttributesVC
    
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder: aDecoder]) {
        errorColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
        successColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
        queuedColor = [UIColor colorWithRed:0.574 green:0.566 blue:0 alpha:1];
        
        [NSUserDefaults.standardUserDefaults registerDefaults: @{attributeBoolValueKey: @YES, attributeStringValueKey: @"", attributeNumberValueKey: @(0), attributeDateValueKey: [NSDate date], attributeNameKey: @""}];
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        datePicker = [[UIDatePicker alloc] init];
        datePicker.accessibilityIdentifier = @"datePicker";
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        keyboardDoneButtonView = [[UIToolbar alloc] init];
        keyboardDoneButtonView.barStyle = UIBarStyleDefault;
        keyboardDoneButtonView.translucent = YES;
        keyboardDoneButtonView.tintColor = nil;
        
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
        doneButton.accessibilityIdentifier = @"doneButton";
        keyboardDoneButtonView.items = @[ doneButton ];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateUserAttributesError:) name:UpdateUserAttributesError object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateUserAttributesSuccess:) name:UpdateUserAttributesSuccess object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deleteUserAttributesError:) name:DeleteUserAttributesError object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deleteUserAttributesSuccess:) name:DeleteUserAttributesSuccess object:nil];
    }
    
    return self;
}
    
-(void)deleteUserAttributesSuccess: (NSNotification*)note {
    NSArray * keys = note.userInfo[@"keys"];
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Deleted User Attributes Named\n\"%@\"", [keys componentsJoinedByString:@"\n"] ], @"color": successColor}];
}
    
-(void)deleteUserAttributesError: (NSNotification*)note {
    NSArray * keys = note.userInfo[@"keys"];
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Couldn't Delete User Attributes Named\n\"%@\"\nbecause %@", [keys componentsJoinedByString:@"\n"], note.userInfo[@"error"] ], @"color": errorColor}];
}
    
-(void)updateUserAttributesSuccess: (NSNotification*)note {
    NSMutableArray * keyvalues = [NSMutableArray array];
    for (NSString * key in note.userInfo[@"attributes"] ) {
        [keyvalues addObject: [NSString stringWithFormat: @"%@=%@", key, note.userInfo[@"attributes"][key]]];
    }
    
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Updated User Attributes\n%@", [keyvalues componentsJoinedByString:@"\n"] ], @"color": successColor}];
}
    
-(void)updateUserAttributesError: (NSNotification*)note {
    NSMutableArray * keyvalues = [NSMutableArray array];
    for (NSString * key in note.userInfo[@"attributes"] ) {
        [keyvalues addObject: [NSString stringWithFormat: @"%@=%@", key, note.userInfo[@"attributes"][key]]];
    }
    
    [self updateStatus: @{ @"text": [NSString stringWithFormat: @"Couldn't Update User Attributes\n%@\nbecause %@", [keyvalues componentsJoinedByString:@"\n"], note.userInfo[@"error"] ], @"color": errorColor}];
}
    
-(void) updateStatus: (NSDictionary*) status {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:status waitUntilDone:false];
        return;
    }
    
    self.statusLabel.textColor = status[@"color"];
    self.statusLabel.text = status[@"text"];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.valueTypeControl.selectedSegmentIndex = [NSUserDefaults.standardUserDefaults integerForKey: attributeValueTypeKey];
    self.valueTypeControl.accessibilityIdentifier = @"attributeType";
    self.operationTypeControl.selectedSegmentIndex = [NSUserDefaults.standardUserDefaults integerForKey: attributeOperationKey];
    self.operationTypeControl.accessibilityIdentifier = @"attributeOperation";
    self.nameTextField.text = [NSUserDefaults.standardUserDefaults objectForKey: attributeNameKey];
    [self updateValueControls];
}
    
- (IBAction)addQueueTap:(id)sender {
    [self.valueTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    
    NSString * name = [NSUserDefaults.standardUserDefaults objectForKey: attributeNameKey];
    
    switch (self.operationTypeControl.selectedSegmentIndex) {
        case UpdateOperation:
        switch (self.valueTypeControl.selectedSegmentIndex) {
            case DateValue:
            {
                NSDate * dateValue = [NSUserDefaults.standardUserDefaults objectForKey: attributeDateValueKey];
                [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, dateValue], @"color": queuedColor}];
                [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: dateValue}];
                break;
            }
            case StringValue:
            {
                NSString * stringValue = [NSUserDefaults.standardUserDefaults stringForKey: attributeStringValueKey];
                [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, stringValue], @"color": queuedColor}];
                [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: stringValue}];
                break;
            }
            case BoolValue:
            {
                BOOL boolValue = [NSUserDefaults.standardUserDefaults boolForKey: attributeBoolValueKey];
                [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, @(boolValue)], @"color": queuedColor}];
                [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: @(boolValue) }];
                break;
            }
            case NumberValue:
            {
                NSNumber * numberValue = [NSUserDefaults.standardUserDefaults objectForKey: attributeNumberValueKey];
                [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, numberValue], @"color": queuedColor}];
                [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: numberValue}];
                break;
            }
        }
        
        break;
        case DeleteOperation:
        [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Removal\nName \"%@\"", name], @"color": queuedColor}];
        [MCEAttributesQueueManager.sharedInstance deleteUserAttributes: @[name]];
        break;
    }
}
    
- (IBAction)valueTypeTap:(id)sender {
    [NSUserDefaults.standardUserDefaults setInteger: self.valueTypeControl.selectedSegmentIndex forKey: attributeValueTypeKey];
    [self updateValueControls];
}
    
-(void)hideAllValueControls {
    self.valueTextField.enabled = false;
    self.valueTextField.alpha = 1;
    self.valueTextField.text = @"No value required for delete operation";
    self.valueTypeControl.enabled = false;
    self.boolSwitch.enabled = false;
    self.boolSwitch.alpha = 0;
    self.booleanView.alpha = 0;
}
    
-(void)showTextValueControls {
    [self.valueTextField resignFirstResponder];
    self.valueTextField.enabled = true;
    self.valueTextField.alpha = 1;
    self.valueTypeControl.enabled = true;
    self.boolSwitch.enabled = false;
    self.boolSwitch.alpha = 0;
    self.booleanView.alpha = 0;
}
    
-(void)showBoolValueControls {
    self.valueTextField.enabled = false;
    self.valueTextField.alpha = 0;
    self.valueTypeControl.enabled = true;
    self.boolSwitch.enabled = true;
    self.boolSwitch.alpha = 1;
    self.booleanView.alpha = 1;
}
    
-(void)updateValueControls {
    switch (self.operationTypeControl.selectedSegmentIndex) {
        case UpdateOperation:
        switch (self.valueTypeControl.selectedSegmentIndex) {
            case BoolValue:
            {
                [self showBoolValueControls];
                self.boolSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey: attributeBoolValueKey];
                break;
            }
            case DateValue:
            {
                [self showTextValueControls];
                NSDate * date = [NSUserDefaults.standardUserDefaults objectForKey: attributeDateValueKey];
                self.valueTextField.text = [dateFormatter stringFromDate: date];
                datePicker.date = date;
                break;
            }
            case StringValue:
            {
                [self showTextValueControls];
                self.valueTextField.keyboardType = UIKeyboardTypeDefault;
                self.valueTextField.text = [NSUserDefaults.standardUserDefaults stringForKey: attributeStringValueKey];
                break;
            }
            case NumberValue:
            {
                self.valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
                [self showTextValueControls];
                NSNumber * numberValue = [NSUserDefaults.standardUserDefaults objectForKey: attributeNumberValueKey];
                self.valueTextField.text = [numberValue stringValue];
                break;
            }
        }
        break;
        case DeleteOperation:
        [self hideAllValueControls];
        break;
    }
}
    
- (IBAction)operationTypeTap:(id)sender {
    [NSUserDefaults.standardUserDefaults setInteger: self.operationTypeControl.selectedSegmentIndex forKey: attributeOperationKey];
    [self updateValueControls];
}
    
-(IBAction)boolValueChanged: (id)sender {
    [NSUserDefaults.standardUserDefaults setBool: self.boolSwitch.on forKey: attributeBoolValueKey];
}
    
-(void) doneClicked: (id)sender {
    if(self.valueTextField.isFirstResponder) {
        [self.valueTextField resignFirstResponder];
        [self saveValue];
    } else if(self.nameTextField.isFirstResponder) {
        [self.nameTextField resignFirstResponder];
        [self saveName];
    }
}
    
-(void) saveName {
    [NSUserDefaults.standardUserDefaults setObject: self.nameTextField.text forKey: attributeNameKey];
}
    
-(void) saveValue {
    switch (self.valueTypeControl.selectedSegmentIndex) {
        case DateValue:
        {
            [NSUserDefaults.standardUserDefaults setObject: datePicker.date forKey: attributeDateValueKey];
            self.valueTextField.text = [dateFormatter stringFromDate: datePicker.date];
            break;
        }
        case StringValue:
        {
            [NSUserDefaults.standardUserDefaults setObject: self.valueTextField.text forKey: attributeStringValueKey];
            break;
        }
        case NumberValue:
        {
            NSNumber * numberValue = [numberFormatter numberFromString: self.valueTextField.text];
            [NSUserDefaults.standardUserDefaults setObject: numberValue forKey: attributeNumberValueKey];
            break;
        }
    }
}
    
    // UITextFieldDelegate Methods
    
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([textField isEqual: self.valueTextField]) {
        [self saveValue];
    } else if([textField isEqual: self.nameTextField]) {
        [self saveName];
    }
    return false;
}
    
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual: self.valueTextField]) {
        if(self.valueTypeControl.selectedSegmentIndex == DateValue) {
            self.valueTextField.inputView = datePicker;
        } else {
            self.valueTextField.inputView = nil;
        }
    }
    textField.inputAccessoryView = keyboardDoneButtonView;
    [keyboardDoneButtonView sizeToFit];
}
    
    @end

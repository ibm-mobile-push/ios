/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2019
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

// TODO
// UI Tests
// Allow sending delayed (non immediate) events

#import "EventVC.h"
#import "AttributesVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

typedef enum : NSUInteger {
    CustomEvent,
    SimulateEvent
} EventType;

typedef enum : NSUInteger {
    AppEvent,
    ActionEvent,
    InboxEvent,
    GeofenceEvent,
    iBeaconEvent
} SimulatedEvents;

@interface EventVC () {
    UIColor * errorColor;
    UIColor * successColor;
    UIColor * queuedColor;
    UIDatePicker * datePicker;
    NSDateFormatter * dateFormatter;
    UIToolbar * keyboardDoneButtonView;
    NSNumberFormatter * numberFormatter;
}
@end

@implementation EventVC

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
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sendEventSuccess:) name:MCEEventSuccess object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sendEventFailure:) name:MCEEventFailure object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    return self;
}

-(void)keyboardNotification:(NSNotification*)note {
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if(endFrame.origin.y >= UIScreen.mainScreen.bounds.size.height) {
        self.keyboardHeightLayoutConstraint.constant = 0.0;
    } else {
        self.keyboardHeightLayoutConstraint.constant = endFrame.size.height;
    }
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void) doneClicked: (id)sender {
     if(self.nameField.isFirstResponder) {
         [self.nameField resignFirstResponder];
     } else if(self.attributionField.isFirstResponder) {
         [self.attributionField resignFirstResponder];
     } else if(self.mailingIdField.isFirstResponder) {
         [self.mailingIdField resignFirstResponder];
     } else if(self.attributeNameField.isFirstResponder) {
         [self.attributeNameField resignFirstResponder];
     } else if(self.attributeValueField.isFirstResponder) {
         if(self.attributeTypeSwitch.selectedSegmentIndex == DateValue) {
             self.attributeValueField.text = [dateFormatter stringFromDate: datePicker.date];
         }
         [self.attributeValueField resignFirstResponder];
     }
}

-(void)sendEventFailure:(NSNotification*)note {
    NSDictionary * events = note.userInfo[@"events"];
    NSError * error = note.userInfo[@"error"];
    NSMutableArray * eventStrings = [NSMutableArray array];
    for(MCEEvent * event in events) {
        [eventStrings addObject: [NSString stringWithFormat: @"name: %@, type: %@", event.name, event.type]];
    }
    [self updateStatus: @{@"color": errorColor, @"text": [NSString stringWithFormat: @"Couldn't send events: %@, because: %@", [eventStrings componentsJoinedByString:@","], error]}];
}

-(void)sendEventSuccess:(NSNotification*)note {
    NSDictionary * events = note.userInfo[@"events"];
    NSMutableArray * eventStrings = [NSMutableArray array];
    for(MCEEvent * event in events) {
        [eventStrings addObject: [NSString stringWithFormat: @"name: %@, type: %@", event.name, event.type]];
    }
    [self updateStatus: @{@"color": successColor, @"text": [NSString stringWithFormat: @"Sent events: %@", [eventStrings componentsJoinedByString:@","]]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customEvent.accessibilityIdentifier = @"customEvent";
    self.simulateEvent.accessibilityIdentifier = @"simulateEvent";
    self.typeSwitch.accessibilityIdentifier = @"typeSwitch";
    self.attributeTypeSwitch.accessibilityIdentifier = @"attributeTypeSwitch";
    self.nameSwitch.accessibilityIdentifier = @"nameSwitch";
    [self updateTypeSelections:self];
}

-(void)sendEvent:(id)sender {
    NSString * name = nil;
    NSString * type = nil;
    NSString * attribution = self.attributionField.text.length ? self.attributionField.text : nil;
    NSString * mailingId = self.mailingIdField.text.length ? self.mailingIdField.text : nil;
    
    [self doneClicked: self];
    switch(self.customEvent.selectedSegmentIndex) {
        case CustomEvent:
            type = @"custom";
            name = self.nameField.text.length ? self.nameField.text : nil;
            break;
        case SimulateEvent:
            if(self.typeSwitch.selectedSegmentIndex != UISegmentedControlNoSegment) {
                type = [self.typeSwitch titleForSegmentAtIndex: self.typeSwitch.selectedSegmentIndex];
            }
            if(self.nameSwitch.selectedSegmentIndex != UISegmentedControlNoSegment) {
                name = [self.nameSwitch titleForSegmentAtIndex: self.nameSwitch.selectedSegmentIndex];
            }
            break;
    }
    
    NSDictionary * attributes = nil;
    NSString * attributeValue = self.attributeValueField.text;
    NSString * attributeName = self.attributeNameField.text;
    if(attributeName.length) {
        switch (self.attributeTypeSwitch.selectedSegmentIndex) {
            case DateValue: {
                NSDate * date = [dateFormatter dateFromString: attributeValue];
                if(date) {
                    attributes = @{attributeName: date};
                }
                break;
            }
            case StringValue: {
                if(attributeValue.length) {
                    attributes = @{attributeName: attributeValue};
                }
                break;
            }
            case NumberValue: {
                NSNumber * number = [numberFormatter numberFromString: attributeValue];
                if(number) {
                    attributes = @{attributeName: number};
                }
                break;
            }
            case BoolValue: {
                NSNumber * number = @(self.booleanSwitch.on);
                attributes = @{attributeName: number};
                break;
            }
        }
    }

    if(name && type) {
        MCEEvent * event = [[MCEEvent alloc] initWithName:name type:type timestamp:nil attributes:attributes attribution:attribution mailingId:mailingId];
        [MCEEventService.sharedInstance addEvent:event immediate:TRUE];
        [self updateStatus: @{@"color": queuedColor, @"text": [NSString stringWithFormat: @"Queued Event with name: %@, type: %@", name, type]}];
    }
}

-(void) updateStatus: (NSDictionary*) status {
    if(!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:status waitUntilDone:false];
        return;
    }
    
    self.eventStatus.textColor = status[@"color"];
    self.eventStatus.text = status[@"text"];
}

- (IBAction) updateTypeSelections:(id)sender {
    [self.attributeTypeSwitch setEnabled: true];
    [self.attributeNameField setEnabled: true];
    [self.attributeValueField setEnabled: true];
    [self.booleanSwitch setEnabled: true];

    [self doneClicked: self];
    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        [self.attributeTypeSwitch setEnabled:true forSegmentAtIndex:i];
    }

    switch(self.customEvent.selectedSegmentIndex) {
        case CustomEvent:
            self.nameSwitch.hidden = TRUE;
            self.nameField.hidden = FALSE;
            self.simulateEvent.enabled = FALSE;
            [self updateTypeSegments:@[@"custom"]];
            break;
        case SimulateEvent:
            self.nameField.hidden = TRUE;
            self.nameSwitch.hidden = FALSE;
            self.simulateEvent.enabled = TRUE;

            switch (self.simulateEvent.selectedSegmentIndex) {
                case AppEvent:
                    [self updateTypeSegments:@[@"application"]];
                    [self updateNameSegments:@[@"sessionStarted", @"sessionEnded", @"uiPushEnabled", @"uiPushDisabled"]];
                    
                    switch(self.nameSwitch.selectedSegmentIndex) {
                        case 0:
                            [self allowNoAttributes];
                            break;
                        case 1:
                            self.attributeNameField.text = @"sessionLength";
                            [self onlyAllowNumberAttributes];
                            break;
                        case 2:
                        case 3:
                            [self allowNoAttributes];
                            break;
                    }
                    break;
                case ActionEvent:
                    [self updateTypeSegments:@[SimpleNotificationSource, InboxSource, InAppSource]];
                    [self updateNameSegments:@[@"urlClicked", @"appOpened", @"phoneNumberClicked", @"inboxMessageOpened"]];
                    switch(self.nameSwitch.selectedSegmentIndex) {
                        case 0: // urlClicked
                            [self onlyAllowStringAttributes];
                            self.attributeNameField.text = @"url";
                            break;
                        case 1: // appOpened
                            [self allowNoAttributes];
                            break;
                        case 2: // phoneNumberClicked
                            [self onlyAllowNumberAttributes];
                            self.attributeNameField.text = @"phoneNumber";
                            break;
                        case 3: // inboxMessageOpened
                            [self onlyAllowStringAttributes];
                            self.attributeNameField.text = @"richContentId";
                            break;
                    }
                    break;
                case InboxEvent:
                    [self updateTypeSegments:@[@"inbox"]];
                    [self updateNameSegments:@[@"messageOpened"]];
                    [self onlyAllowStringAttributes];
                    self.attributeNameField.text = @"inboxMessageId";
                    break;
                case GeofenceEvent:
                    [self updateTypeSegments:@[@"geofence"]];
                    [self updateNameSegments:@[@"disabled", @"enabled", @"enter", @"exit"]];
                    break;
                case iBeaconEvent:
                    [self updateTypeSegments:@[@"ibeacon"]];
                    [self updateNameSegments:@[@"disabled", @"enabled", @"enter", @"exit"]];
                    break;
            }
            
            if(self.simulateEvent.selectedSegmentIndex == GeofenceEvent || self.simulateEvent.selectedSegmentIndex == iBeaconEvent) {
                switch(self.nameSwitch.selectedSegmentIndex) {
                    case 0: // disabled
                        [self onlyAllowStringAttributes];
                        self.attributeNameField.text = @"reason";
                        self.attributeValueField.text = @"not_enabled";
                        break;
                    case 1: // enabled
                        [self allowNoAttributes];
                        break;
                    case 2: // enter
                    case 3: // exit
                        [self onlyAllowStringAttributes];
                        self.attributeNameField.text = @"locationId";
                        break;
                }
            }
    }
    
    switch (self.attributeTypeSwitch.selectedSegmentIndex) {
        case DateValue:
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            if(![dateFormatter dateFromString: self.attributeValueField.text]) {
                self.attributeValueField.text = @"";
            }
            break;
        case StringValue:
            self.attributeValueField.keyboardType = UIKeyboardTypeDefault;
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            break;
        case NumberValue:
            self.attributeValueField.keyboardType = UIKeyboardTypeDecimalPad;
            self.attributeValueField.hidden = FALSE;
            self.booleanContainer.hidden = TRUE;
            if(![numberFormatter numberFromString:self.attributeValueField.text]) {
                self.attributeValueField.text = @"";
            }
            break;
        case BoolValue:
            self.attributeValueField.hidden = TRUE;
            self.booleanContainer.hidden = FALSE;
            break;
    }
    
    [self.view layoutSubviews];
}

-(void)allowNoAttributes {
    self.attributeNameField.text = @"";
    self.attributeValueField.text = @"";
    [self allowOnlyAttributeType: UISegmentedControlNoSegment];
    [self.attributeNameField setEnabled:false];
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeValueField setEnabled: false];
    [self.booleanSwitch setEnabled: false];

    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        [self.attributeTypeSwitch setEnabled:false forSegmentAtIndex:i];
    }
}

-(void)allowOnlyAttributeType: (int)allowed {
    for(int i=0; i<self.attributeTypeSwitch.numberOfSegments;i++) {
        if(i == allowed) {
            [self.attributeTypeSwitch setEnabled:true forSegmentAtIndex:i];
        } else {
            [self.attributeTypeSwitch setEnabled:false forSegmentAtIndex:i];
        }
    }
}

-(void)onlyAllowStringAttributes {
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeNameField setEnabled: true];
    [self.booleanSwitch setEnabled: false];
    self.attributeTypeSwitch.selectedSegmentIndex = StringValue;
    [self allowOnlyAttributeType: StringValue];
}

-(void)onlyAllowNumberAttributes {
    [self.attributeTypeSwitch setEnabled:false];
    [self.attributeNameField setEnabled: true];
    [self.booleanSwitch setEnabled: false];
    self.attributeTypeSwitch.selectedSegmentIndex = NumberValue;
    [self allowOnlyAttributeType: NumberValue];
}

-(void)updateNameSegments: (NSArray*) names {
    [self update: self.nameSwitch segments: names];
}

-(void)updateTypeSegments: (NSArray*) types {
    [self update: self.typeSwitch segments: types];
}

-(void)update: (UISegmentedControl*)control segments: (NSArray*) segments {
    while(control.numberOfSegments > segments.count) {
        [control removeSegmentAtIndex:0 animated:FALSE];
    }
    while(control.numberOfSegments < segments.count) {
        [control insertSegmentWithTitle:@"" atIndex:0 animated:FALSE];
    }
    NSUInteger index = 0;
    for(NSString * segment in segments) {
        [control setTitle:segment forSegmentAtIndex:index++];
    }
    
    NSUInteger selected = control.selectedSegmentIndex;
    if(selected == UISegmentedControlNoSegment || selected > segments.count - 1) {
        selected = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        control.selectedSegmentIndex = UISegmentedControlNoSegment;
        dispatch_async(dispatch_get_main_queue(), ^{
            control.selectedSegmentIndex = selected;
        });
    });
}


// UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual: self.attributeValueField]) {
        if(self.attributeTypeSwitch.selectedSegmentIndex == DateValue) {
            self.attributeValueField.inputView = datePicker;
        } else {
            self.attributeValueField.inputView = nil;
        }
    }
    textField.inputAccessoryView = keyboardDoneButtonView;
    [keyboardDoneButtonView sizeToFit];
}

@end

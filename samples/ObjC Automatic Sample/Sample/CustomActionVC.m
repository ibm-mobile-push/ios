/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2019, 2019
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "CustomActionVC.h"
@import IBMMobilePush;

@interface CustomActionVC ()
@property UIColor * errorColor;
@property UIColor * successColor;
@property UIColor * warningColor;
@end

@implementation CustomActionVC

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.errorColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
    self.successColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    self.warningColor = [UIColor colorWithRed:0.574 green:0.566 blue:0 alpha:1];

    self.keyboardDoneButtonView = [[UIToolbar alloc] init];
    self.keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    self.keyboardDoneButtonView.translucent = YES;
    self.keyboardDoneButtonView.tintColor = nil;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)];
    doneButton.accessibilityIdentifier = @"doneButton";
    self.keyboardDoneButtonView.items = @[ doneButton ];
    
    [NSNotificationCenter.defaultCenter addObserverForName:MCECustomPushNotYetRegistered object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary * action = note.userInfo[@"action"];
        self.statusLabel.textColor = self.warningColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Previously Registered Custom Action Received: %@", action];
    }];

    [NSNotificationCenter.defaultCenter addObserverForName:MCECustomPushNotRegistered object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary * action = note.userInfo[@"action"];
        self.statusLabel.textColor = self.errorColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Unregistered Custom Action Received: %@", action];
    }];

    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue: NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
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
    }];
}

-(void) doneClicked: (id)sender {
    [self.typeField resignFirstResponder];
    [self.valueField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.inputAccessoryView = self.keyboardDoneButtonView;
    [self.keyboardDoneButtonView sizeToFit];
}

// This method simulates how custom actions receive push actions
-(void)receiveCustomAction:(NSDictionary *) action {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.textColor = self.successColor;
        self.statusLabel.text = [NSString stringWithFormat: @"Received Custom Action: %@", action];
    });
}

// This method simulates a custom action registering to receive push actions
- (IBAction)registerCustomAction:(id)sender {
    self.statusLabel.textColor = self.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Registering Custom Action: %@", self.typeField.text];
    [MCEActionRegistry.sharedInstance registerTarget:self withSelector:@selector(receiveCustomAction:) forAction:self.typeField.text];
}

// This method simulates a user clicking on a push message with a custom action
- (IBAction)sendCustomAction:(id)sender {
    NSDictionary * action = @{@"type": self.typeField.text, @"value": self.valueField.text};
    NSDictionary * payload = @{@"notification-action": action};
    self.statusLabel.textColor = self.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Sending Custom Action: %@", action];
    [MCEActionRegistry.sharedInstance performAction:action forPayload:payload source:@"internal" attributes:nil userText:nil];
}

// This method shows how to unregister a custom action
- (IBAction)unregisterCustomAction:(id)sender {
    self.statusLabel.textColor = self.successColor;
    self.statusLabel.text = [NSString stringWithFormat: @"Unregistered Action: %@", self.typeField.text];
    [MCEActionRegistry.sharedInstance unregisterAction:self.typeField.text];
}

@end

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *customEvent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *simulateEvent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *attributionField;
@property (weak, nonatomic) IBOutlet UITextField *mailingIdField;
@property (weak, nonatomic) IBOutlet UITextField *attributeNameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *attributeTypeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *attributeValueField;
- (IBAction)sendEvent:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *booleanSwitch;
@property (weak, nonatomic) IBOutlet UILabel *eventStatus;
@property (weak, nonatomic) IBOutlet UIView *booleanContainer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nameSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * keyboardHeightLayoutConstraint;
- (IBAction) updateTypeSelections:(id)sender;
@end

NS_ASSUME_NONNULL_END

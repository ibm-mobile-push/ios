/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

typedef enum : NSUInteger {
    DateValue,
    StringValue,
    BoolValue,
    NumberValue
} ValueTypes;

typedef enum : NSUInteger {
    UpdateOperation,
    DeleteOperation
} OperationTypes;

static NSString * attributeBoolValueKey = @"attributeBoolValueKey";
static NSString * attributeStringValueKey = @"attributeStringValueKey";
static NSString * attributeNumberValueKey = @"attributeNumberValueKey";
static NSString * attributeDateValueKey = @"attributeDateValueKey";
static NSString * attributeNameKey = @"attributeNameKey";
static NSString * attributeOperationKey = @"attributeOperationKey";
static NSString * attributeValueTypeKey = @"attributeValueTypeKey";

@interface AttributesVC : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel * statusLabel;
@property (weak, nonatomic) IBOutlet UITextField * nameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *valueTypeControl;
@property (weak, nonatomic) IBOutlet UITextField * valueTextField;
@property (weak, nonatomic) IBOutlet UISwitch *boolSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *operationTypeControl;
@property (weak, nonatomic) IBOutlet UIButton *addQueueButton;
@property (weak, nonatomic) IBOutlet UIButton *executeQueueButton;
@property (weak, nonatomic) IBOutlet UIView *booleanView;
- (IBAction)addQueueTap:(id)sender;
- (IBAction)valueTypeTap:(id)sender;
- (IBAction)operationTypeTap:(id)sender;
-(IBAction)boolValueChanged: (id)sender;
@end

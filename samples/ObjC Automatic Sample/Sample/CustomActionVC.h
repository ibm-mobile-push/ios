/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2019, 2019
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import <UIKit/UIKit.h>
@import IBMMobilePush;

NS_ASSUME_NONNULL_BEGIN

@interface CustomActionVC : UIViewController <MCEActionProtocol, UITextFieldDelegate>
- (IBAction)registerCustomAction:(id)sender;
- (IBAction)sendCustomAction:(id)sender;
- (IBAction)unregisterCustomAction:(id)sender;
@property UIToolbar * keyboardDoneButtonView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * keyboardHeightLayoutConstraint;
@end

NS_ASSUME_NONNULL_END

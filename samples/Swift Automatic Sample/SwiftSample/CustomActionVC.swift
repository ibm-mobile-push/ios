/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2019, 2019
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

class CustomActionVC: UIViewController, UITextFieldDelegate, MCEActionProtocol {
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    let keyboardToolbar = UIToolbar()
    
    let colors = (
        error: UIColor(red: 0.5, green: 0, blue: 0, alpha: 1),
        success: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
        warning: UIColor(red: 0.574, green: 0.566, blue: 0, alpha: 1)
    )
    
    // This method simulates a custom action registering to receive push actions
    @IBAction func registerCustomAction(_ sender: Any) {
        guard let type = typeField.text else {
            return
        }
        statusLabel.text = "Registering Custom Action: \(type)"
        statusLabel.textColor = colors.success
        MCEActionRegistry.shared.registerTarget(self, with: #selector(receiveCustomAction(action:)), forAction: type)
    }
    
    // This method shows how to unregister a custom action
    @IBAction func unregisterCustomAction(_ sender: Any) {
        guard let type = typeField.text else {
            return
        }
        statusLabel.textColor = colors.success
        statusLabel.text = "Unregistered Action: \(type)"
        MCEActionRegistry.shared.unregisterAction(type)
    }
    
    // This method simulates a user clicking on a push message with a custom action
    @IBAction func sendCustomAction(_ sender: Any) {
        guard let type = typeField.text, let value = valueField.text else {
            return
        }
        let action = ["type": type, "value": value]
        let payload = ["notification-action": action]
        statusLabel.textColor = colors.success
        statusLabel.text = "Sending Custom Action: \(action)"
        MCEActionRegistry.shared.performAction(action, forPayload: payload, source: "internal", attributes: nil, userText: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        keyboardToolbar.barStyle = .default
        keyboardToolbar.isTranslucent = true
        keyboardToolbar.tintColor = nil
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        doneButton.accessibilityIdentifier = "doneButton"
        keyboardToolbar.items = [doneButton]
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.customPushNotYetRegistered.rawValue, object: nil, queue: .main) { (note) in
            guard let action = note.userInfo?["action"] as? [String:Any] else {
                return
            }
            self.statusLabel.textColor = self.colors.warning
            self.statusLabel.text = "Previously Registered Custom Action Received: \(action)"
        }
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.customPushNotRegistered.rawValue, object: nil, queue: .main) { (note) in
            guard let action = note.userInfo?["action"] as? [String:Any] else {
                return
            }
            self.statusLabel.textColor = self.colors.error
            self.statusLabel.text = "Unregistered Custom Action Received: \(action)"
        }
        
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (note) in
            if let userInfo = note.userInfo,
                let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let optionsInteger = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                let options = UIView.AnimationOptions(rawValue: optionsInteger)
                
                if frame.origin.y >= UIScreen.main.bounds.size.height {
                    self.keyboardHeightLayoutConstraint.constant = 0
                } else {
                    self.keyboardHeightLayoutConstraint.constant = frame.size.height
                }
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func doneClicked() {
        typeField.resignFirstResponder()
        valueField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }
    
    // This method simulates how custom actions receive push actions
    @objc func receiveCustomAction(action: NSDictionary) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Received Custom Action: \(action)"
            self.statusLabel.textColor = self.colors.success
        }
    }
    
    
}

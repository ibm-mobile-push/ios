/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import IBMMobilePush
import UIKit

extension UIColor {
    class var failure: UIColor {
        return UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
    }
    
    class var queued: UIColor {
        return UIColor(red: 0.574, green: 0.566, blue: 0, alpha: 1)
    }
    
    class var success: UIColor {
        return UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
    }
}

enum ValueTypes: Int, CaseIterable {
    case date
    case string
    case bool
    case number
}

class AttributesVC: UIViewController {
    
    enum OperationTypes: Int {
        case update
        case delete
    }
    
    enum UserDefaultKeys: String {
        case bool = "attributeBoolValueKey"
        case string = "attributeStringValueKey"
        case number = "attributeNumberValueKey"
        case date = "attributeDateValueKey"
        case name = "attributeNameKey"
        case operation = "attributeOperationKey"
        case valueType = "attributeValueTypeKey"
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var valueTypeControl: UISegmentedControl!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var boolSwitch: UISwitch!
    @IBOutlet weak var operationTypeControl: UISegmentedControl!
    @IBOutlet weak var addQueueButton: UIButton!
    @IBOutlet weak var booleanView: UIView!
    
    var datePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    var keyboardToolbar = UIToolbar()
    var numberFormatter = NumberFormatter()
    
    @IBAction func addQueueTap(sender: Any) {
        valueTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
        guard let name = UserDefaults.standard.string(forKey: UserDefaultKeys.name.rawValue), let operation = OperationTypes(rawValue: operationTypeControl.selectedSegmentIndex), let valueType = ValueTypes(rawValue: valueTypeControl.selectedSegmentIndex) else {
            return
        }
        
        switch operation {
        case .update:
            switch valueType {
            case .bool:
                let boolValue = UserDefaults.standard.bool(forKey: UserDefaultKeys.bool.rawValue)
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(boolValue)", color: .queued)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:boolValue])
                break
            case .date:
                guard let dateValue = UserDefaults.standard.object(forKey: UserDefaultKeys.date.rawValue) as? Date else {
                    return
                }
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(dateValue)", color: .queued)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:dateValue])
                break
            case .number:
                guard let numberValue = UserDefaults.standard.object(forKey: UserDefaultKeys.number.rawValue) as? NSNumber else {
                    return
                }
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(numberValue)", color: .queued)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:numberValue])
                break
            case .string:
                guard let stringValue = UserDefaults.standard.string(forKey: UserDefaultKeys.string.rawValue) else {
                    return
                }
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(stringValue)", color: .queued)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:stringValue])
                break
            }
            break
        case .delete:
            updateStatus(text: "Queued User Attribute Removal\nName \"\(name)\"", color: .queued)
            MCEAttributesQueueManager.shared.deleteUserAttributes([name])
            break
        }
    }
    
    @IBAction func valueTypeTap(sender: Any) {
        UserDefaults.standard.set(valueTypeControl.selectedSegmentIndex, forKey: UserDefaultKeys.valueType.rawValue)
        updateValueControls()
    }
    
    @IBAction func operationTypeTap(sender: Any) {
        UserDefaults.standard.set(operationTypeControl.selectedSegmentIndex, forKey: UserDefaultKeys.operation.rawValue)
        updateValueControls()
    }
    
    @IBAction func boolValueChanged(sender: Any) {
        UserDefaults.standard.set(boolSwitch.isOn, forKey: UserDefaultKeys.bool.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        UserDefaults.standard.register(defaults: [UserDefaultKeys.bool.rawValue : true, UserDefaultKeys.string.rawValue: "", UserDefaultKeys.number.rawValue: 0, UserDefaultKeys.date.rawValue: Date(), UserDefaultKeys.name.rawValue: ""])
        
        numberFormatter.numberStyle = .decimal
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        datePicker.datePickerMode = .dateAndTime
        datePicker.accessibilityIdentifier = "datePicker"
        datePicker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        keyboardToolbar.barStyle = .default
        keyboardToolbar.isTranslucent = true
        keyboardToolbar.tintColor = nil
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        doneButton.accessibilityIdentifier = "doneButton"
        keyboardToolbar.items = [doneButton]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserAttributesSuccess), name: MCENotificationName.UpdateUserAttributesSuccess.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserAttributesError), name: MCENotificationName.UpdateUserAttributesError.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteUserAttributesError), name: MCENotificationName.DeleteUserAttributesError.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteUserAttributesSuccess), name: MCENotificationName.DeleteUserAttributesSuccess.rawValue, object: nil)
    }
    
    @objc func doneClicked(sender: Any) {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
            saveValue()
        } else if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
            saveName()
        }
        
    }
    
    func saveName() {
        UserDefaults.standard.set(nameTextField.text, forKey: UserDefaultKeys.name.rawValue)
    }
    
    func saveValue() {
        guard let valueType = ValueTypes(rawValue: valueTypeControl.selectedSegmentIndex) else {
            return
        }
        switch valueType {
        case .date:
            UserDefaults.standard.set(datePicker.date, forKey: UserDefaultKeys.date.rawValue)
            valueTextField.text = dateFormatter.string(from: datePicker.date)
            break
        case .string:
            UserDefaults.standard.set(valueTextField.text, forKey: UserDefaultKeys.string.rawValue)
            break
        case .number:
            guard let text = valueTextField.text else { return }
            let numberValue = numberFormatter.number(from: text)
            UserDefaults.standard.set(numberValue, forKey: UserDefaultKeys.number.rawValue)
            break
        default:
            break
        }
    }
    
    @objc func deleteUserAttributesError(note: NSNotification) {
        guard let userInfo = note.userInfo, let error = userInfo["error"] as? Error, let keys = userInfo["keys"] as? [String] else {
            return
        }
        updateStatus(text: "Couldn't Delete User Attributes Named\n\(keys.joined(separator: "\n"))\nbecause \(error.localizedDescription)", color: .failure)
    }
    
    @objc func deleteUserAttributesSuccess(note: NSNotification) {
        guard let userInfo = note.userInfo, let keys = userInfo["keys"] as? [String] else {
            return
        }
        updateStatus(text: "Deleted User Attributes Named\n\(keys.joined(separator: "\n"))", color: .success)
    }
    
    @objc func updateUserAttributesError(note: NSNotification) {
        guard let userInfo = note.userInfo, let attributes = userInfo["attributes"] as? [String:Any], let error = userInfo["error"] as? Error else {
            return
        }
        var keyvalues = [String]()
        
        for (key, value) in attributes {
            keyvalues.append("\(key)=\(value)")
        }
        
        updateStatus(text: "Couldn't Update User Attributes\n\(keyvalues.joined(separator: "\n"))\nbecause \(error.localizedDescription)", color: .failure)
    }
    
    @objc func updateUserAttributesSuccess(note: NSNotification) {
        guard let userInfo = note.userInfo, let attributes = userInfo["attributes"] as? [String:Any] else {
            return
        }
        var keyvalues = [String]()
        
        for (key, value) in attributes {
            keyvalues.append("\(key)=\(value)")
        }
        
        updateStatus(text: "Updated User Attributes\n\(keyvalues.joined(separator: "\n"))", color: .success)
    }
    
    func updateStatus(text: String, color: UIColor) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
            self.statusLabel.textColor = color
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTypeControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: UserDefaultKeys.valueType.rawValue)
        operationTypeControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: UserDefaultKeys.operation.rawValue)
        nameTextField.text = UserDefaults.standard.string(forKey: UserDefaultKeys.name.rawValue)
        valueTypeControl.accessibilityIdentifier = "attributeType"
        operationTypeControl.accessibilityIdentifier = "attributeOperation"
        updateValueControls()
    }
    
    func hideAllValueControls() {
        valueTextField.isEnabled = false
        valueTextField.alpha = 1
        valueTextField.text = "No value required for delete operation"
        valueTypeControl.isEnabled = false
        boolSwitch.isEnabled = false
        boolSwitch.alpha = 0
        booleanView.alpha = 0
    }
    
    func showTextValueControls() {
        valueTextField.resignFirstResponder()
        valueTextField.isEnabled = true
        valueTextField.alpha = 1
        valueTypeControl.isEnabled = true
        boolSwitch.isEnabled = false
        boolSwitch.alpha = 0
        booleanView.alpha = 0
    }
    
    func showBoolValueControls() {
        valueTextField.isEnabled = false
        valueTextField.alpha = 0
        valueTypeControl.isEnabled = true
        boolSwitch.isEnabled = true
        boolSwitch.alpha = 1
        booleanView.alpha = 1
    }
    
    func updateValueControls() {
        guard let operation = OperationTypes(rawValue: operationTypeControl.selectedSegmentIndex), let valueType = ValueTypes(rawValue: valueTypeControl.selectedSegmentIndex) else {
            return
        }
        
        switch operation {
        case .update:
            switch valueType {
            case .bool:
                showBoolValueControls()
                boolSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultKeys.bool.rawValue)
                break
            case .date:
                showTextValueControls()
                guard let date = UserDefaults.standard.object(forKey: UserDefaultKeys.date.rawValue) as? Date else {
                    return
                }
                valueTextField.text = dateFormatter.string(from: date)
                datePicker.date = date
                break
            case .string:
                showTextValueControls()
                valueTextField.keyboardType = .default
                valueTextField.text = UserDefaults.standard.string(forKey: UserDefaultKeys.string.rawValue)
                break
            case .number:
                valueTextField.keyboardType = .decimalPad
                showTextValueControls()
                guard let numberValue = UserDefaults.standard.object(forKey: UserDefaultKeys.number.rawValue) as? NSNumber else {
                    return
                }
                valueTextField.text = numberValue.stringValue
                break
            }
            break
        case .delete:
            hideAllValueControls()
            break
        }
    }
}

extension AttributesVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let startText = textField.text, let text = startText as? NSString else {
            return false
        }
        textField.text = text.replacingCharacters(in: range, with: string)
        if textField == valueTextField {
            saveValue()
        } else if textField == nameTextField {
            saveName()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == valueTextField {
            if valueTypeControl.selectedSegmentIndex == ValueTypes.date.rawValue {
                valueTextField.inputView = datePicker
            } else {
                valueTextField.inputView = nil
            }
        }
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }
}

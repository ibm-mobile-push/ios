/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum PushActionSections: Int
{
    case standard
    case custom
    static let count: Int = 2
}

enum PushActionItems: Int
{
    case type
    case value
    case json
    static let count: Int = 3
}

enum PushActionTypes: Int
{
    case dial=1
    case url
    case openApp
}

class PushActionsVC : UITableViewController, UITextFieldDelegate, UIActionSheetDelegate
{
    @IBOutlet weak var standardValue: KeyedTextField?
    @IBOutlet weak var customType: KeyedTextField?
    @IBOutlet weak var customValue: KeyedTextField?
    var standardTextColor: UIColor?

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let defaults = UserDefaults.standard
        
        if let pushActionSection = PushActionSections(rawValue: indexPath.section)
        {
            if let pushActionItem = PushActionItems(rawValue: indexPath.item)
            {
                switch(pushActionItem)
                {
                case .type:
                    if pushActionSection == .standard
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "view", for: indexPath as IndexPath)
                        cell.textLabel!.text = "Type"
                        cell.detailTextLabel!.text = defaults.string(forKey: "standardType")
                        return cell
                    }
                    else
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "edit", for: indexPath as IndexPath) as! EditCell
                        cell.textField!.text = "Type"
                        cell.editField!.text = defaults.string(forKey: "customType")
                        customType = cell.editField
                        customType!.indexPath = indexPath as IndexPath
                        customType!.key = "customType"
                        customType!.delegate = self
                        return cell
                    }
                    
                case .value:
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "edit", for: indexPath as IndexPath) as! EditCell
                    cell.textField!.text = "Value"
                    if pushActionSection == .standard
                    {
                        standardValue = cell.editField!
                        standardValue!.delegate=self
                        if let type = defaults.string(forKey: "standardType")
                        {
                            if type == "url"
                            {
                                standardValue!.key = "standardUrlValue"
                            }
                            else if type == "dial"
                            {
                                standardValue!.key = "standardDialValue"
                            }
                        }
                        standardValue!.indexPath = indexPath as IndexPath
                        if let key = standardValue!.key
                        {
                            standardValue!.text = defaults.string(forKey: key)
                        }
                        else
                        {
                            standardValue!.text = ""
                        }
                    }
                    else
                    {
                        customValue = cell.editField!
                        customValue!.delegate=self
                        customValue!.key = "customValue"
                        customValue!.indexPath = indexPath as IndexPath
                        customValue!.text = defaults.string(forKey: customValue!.key!)
                    }
                    
                    return cell
                case .json:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "longview", for: indexPath as IndexPath)
                    cell.textLabel!.text = "JSON"
                    var type: String?
                    var value: String?
                    if pushActionSection == .standard
                    {
                        type = defaults.string(forKey: "standardType")
                        if type == "url"
                        {
                            value = defaults.string(forKey: "standardUrlValue")
                        }
                        else if type == "dial"
                        {
                            value = defaults.string(forKey: "standardDialValue")
                        }
                    }
                    else
                    {
                        type = defaults.string(forKey: "customType")
                        value = defaults.string(forKey: "customValue")
                    }
                    
                    var jsonValue: Any?
                    if let v = value
                    {
                        let valueData = v.data(using: String.Encoding.utf8)
                        do
                        {
                            jsonValue = try JSONSerialization.jsonObject(with: valueData!, options: JSONSerialization.ReadingOptions.allowFragments )
                        }
                        catch _
                        {
                            UIAlertView.init(title: "Value entry invalid", message: "Could not serialize json. Is it valid?", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
                        }
                    }
                    
                    let jsonDict = ((jsonValue != nil) ? ["type": type!, "value": jsonValue!] : ["type": type!] ) as NSDictionary
                    
                    do
                    {
                        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions())
                        var str = String(data: data, encoding: String.Encoding.utf8)
                        str = str?.replacingOccurrences(of: "\\\"", with: "\"")
                        str = str?.replacingOccurrences(of: "\\/", with: "/")
                        cell.detailTextLabel!.text = str
                    }
                    catch _
                    {
                        cell.detailTextLabel!.text = "Could not convert"
                    }
                    return cell
                }
            }
        }
        return UITableViewCell.init()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        switch((indexPath.item, indexPath.section))
        {
        case (1,0):
            standardValue?.becomeFirstResponder()
            break
        case (0,1):
            customType?.becomeFirstResponder()
            break
        case(1,1):
            customValue?.becomeFirstResponder()
            break
        case(0,0):
            let sheet = IndexedActionSheet.init(title: "Select Standard Action", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "dial", "url", "openApp")
            sheet.indexPath = indexPath as NSIndexPath
            sheet.show(in: tableView)
            fallthrough
        default:
            customValue?.resignFirstResponder()
            customType?.resignFirstResponder()
            standardValue?.resignFirstResponder()
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PushActionItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return PushActionSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Standard Action"
        }
        return "Custom Action"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        
        if section == 0
        {
            return "The action opens a dialer to call the number that is specified in the \"value\" key"
        }
        return "Please look at the application code for the implementation of custom actions (customAction). You can use that code as a starting point to create more custom actions. For more details, please see http://ibm.co/1Fp0OEQ"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let keyedTextField = textField as? KeyedTextField
        {
            UserDefaults.standard.set(keyedTextField.text, forKey: keyedTextField.key!)
            let indexPath = keyedTextField.indexPath!
            let jsonIndexPath = IndexPath(item: 2, section: indexPath.section)
            tableView.reloadRows(at: [indexPath, jsonIndexPath], with: .automatic)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if let indexedActionSheet = actionSheet as? IndexedActionSheet
        {
            if let pushActionType = PushActionTypes(rawValue: buttonIndex)
            {
                switch(pushActionType)
                {
                case .dial:
                    UserDefaults.standard.set("dial", forKey: "standardType")
                    break
                case .url:
                    UserDefaults.standard.set("url", forKey: "standardType")
                    break
                case .openApp:
                    UserDefaults.standard.set("openApp", forKey: "standardType")
                    break
                }
            }
            let indexPath = indexedActionSheet.indexPath!
            let jsonIndexPath = IndexPath(item: 2, section: indexPath.section)
            let valueIndexPath = IndexPath(item: 1, section: indexPath.section)
            tableView.reloadRows(at: [indexPath as IndexPath, jsonIndexPath, valueIndexPath], with: .automatic)
        }
    }
}

class IndexedActionSheet : UIActionSheet
{
    var indexPath: NSIndexPath?
}

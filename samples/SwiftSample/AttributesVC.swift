/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum AttributeItems: Int
{
    case name
    case value
    case action
    case sendQueue
    static let count: Int = 4
}

enum Actions: Int
{
    case update
    case delete
}

class AttributesVC : CellStatusTableViewController, UITextFieldDelegate
{
    let observations = ["SetUserAttributes", "UpdateUserAttributes", "DeleteUserAttributes", "SetChannelAttributes", "UpdateChannelAttributes", "DeleteChannelAttributes"]

    @IBOutlet weak var nameField: KeyedTextField?
    @IBOutlet weak var valueField: KeyedTextField?
    @IBOutlet weak var actionField: UISegmentedControl?

    var queue: MCEAttributesQueueManager
    required init?(coder aDecoder: NSCoder) {
        queue = MCEAttributesQueueManager.sharedInstance()
        super.init(coder: aDecoder)
        status = ["client": .normal, "queue": .normal]
        
        let center = NotificationCenter.default
        for observation in observations
        {
            center.addObserver(self, selector: #selector(self.attributesQueueSuccess(note:)), name: NSNotification.Name(observation + "Success"), object: nil)
            center.addObserver(self, selector: #selector(self.attributesQueueError(note:)), name: NSNotification.Name(observation + "Error"), object: nil)
        }
    }
    
    deinit
    {
        let center = NotificationCenter.default
        for observation in observations
        {
            center.removeObserver(self, name: NSNotification.Name(rawValue: observation + "Success"), object: nil)
            center.removeObserver(self, name: NSNotification.Name(observation + "Error"), object: nil)
        }
    }
    
    func attributesQueueSuccess(note: NSNotification)
    {
        status["queue"] = .recieved
        DispatchQueue.main.async() { () -> Void in
            self.tableView.reloadRows(at: [IndexPath(item: 4, section: 0)], with: .automatic)
        }
    }
    
    func attributesQueueError(note: NSNotification)
    {
        status["queue"] = .failed
        DispatchQueue.main.async() { () -> Void in
            self.tableView.reloadRows(at: [IndexPath(item: 4, section: 0)], with: .automatic)
        }
    }
    
    func changeSelect(sender: AnyObject)
    {
        let defaults = UserDefaults.standard
        
        if let actionField = self.actionField
        {
            if let actionValue = Actions(rawValue: actionField.selectedSegmentIndex)
            {
                switch(actionValue)
                {
                case .update:
                    defaults.set("update", forKey: "action")
                    break
                case .delete:
                    defaults.set("delete", forKey: "action")
                    break
                }
            }

            DispatchQueue.main.async() { () -> Void in
                self.tableView.reloadRows(at: [IndexPath(item: 1, section: 0)], with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let defaults = UserDefaults.standard
        if let attributeItem = AttributeItems(rawValue: indexPath.item)
        {
            switch(attributeItem)
            {
            case .name:
                let cell = tableView.dequeueReusableCell(withIdentifier: "edit", for: indexPath as IndexPath) as! EditCell
                nameField = cell.editField!
                nameField!.delegate = self
                nameField!.key = "attributeName"
                nameField!.text = defaults.string(forKey: "attributeName")
                cell.textField!.text = "Enter your attribute"
            case .value:
                let cell = tableView.dequeueReusableCell(withIdentifier: "edit", for: indexPath as IndexPath) as! EditCell
                valueField = cell.editField!
                valueField!.delegate = self
                valueField!.key = "attributeValue"
                valueField!.text = defaults.string(forKey: "attributeValue")
                cell.textField!.text = "Enter your value"
                if(defaults.string(forKey: "action")! == "delete")
                {
                    valueField!.textColor = UIColor.gray
                }
                else
                {
                    valueField!.textColor = UIColor.black
                }
            case .action:
                let cell = tableView.dequeueReusableCell(withIdentifier: "select", for: indexPath as IndexPath) as! EditCell
                cell.textField!.text = "Choose an Action"
                cell.selectField!.addTarget(self, action: #selector(self.changeSelect(sender:)), for: .valueChanged)
                actionField = cell.selectField!
                switch(defaults.string(forKey: "action")!)
                {
                case "set":
                    cell.selectField!.selectedSegmentIndex=0;
                    break
                case "update":
                    cell.selectField!.selectedSegmentIndex=1;
                    break
                case "delete":
                    cell.selectField!.selectedSegmentIndex=2;
                    break
                default:
                    break;
                }
                return cell
            case .sendQueue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "view", for: indexPath as IndexPath)
                cell.textLabel!.text = "Click to send via queue"
                cellStatus(cell: cell, key: "queue")
                return cell
            }
        }
        return UITableViewCell.init()
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AttributeItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Send User Attributes"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.item == 2)
        {
            return 68
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        if let attributeItem = AttributeItems(rawValue: indexPath.item)
        {
            switch(attributeItem)
            {
            case .name:
                nameField?.becomeFirstResponder()
                break
            case .value:
                valueField?.becomeFirstResponder()
                break
            default:
                valueField?.resignFirstResponder()
                nameField?.resignFirstResponder()
            }
            
            
            if(attributeItem == .sendQueue)
            {
                let defaults = UserDefaults.standard
                let action = defaults.string(forKey: "action")
                let name = defaults.string(forKey: "attributeName")
                let value = defaults.string(forKey: "attributeValue")
                if(name == nil || value == nil)
                {
                    UIAlertView.init(title: "Please enter values", message: "Please enter names and values before pressing the send button", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
                    return
                }
            
                switch(action!)
                {
                case "delete":
                    queue.deleteUserAttributes([name!])
                    break
                case "update":
                    queue.updateUserAttributes([name! : value!])
                    break
                default:
                    break                    
                }
                status["queue"] = .sent
            
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadRows(at: [indexPath as IndexPath], with: .automatic)
                })

            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let keyedTextField = textField as? KeyedTextField
        {
            UserDefaults.standard.set(keyedTextField.text, forKey: keyedTextField.key!)
        }
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

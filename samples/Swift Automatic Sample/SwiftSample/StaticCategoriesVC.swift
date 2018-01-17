/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit
import ObjectiveC

enum StaticCategoryItems: Int
{
    case categoryId
    case button1
    case button2

    static let count: Int = 3
}

class StaticCategoriesVC : UITableViewController, UITextFieldDelegate
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normalcell", for: indexPath as IndexPath)
        
        if let categoryItem = StaticCategoryItems(rawValue: indexPath.item)
        {
            switch(categoryItem)
            {
            case .categoryId:
                cell.textLabel!.text = "Category ID"
                cell.detailTextLabel!.text = "Example"
                break
            case .button1:
                cell.textLabel!.text = "Button 1"
                cell.detailTextLabel!.text = "Accept"
                break
            case .button2:
                cell.textLabel!.text = "Button 2"
                cell.detailTextLabel!.text = "Reject"
                break
            }
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return StaticCategoryItems.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if(section==0)
        {
            return "Example Category"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if(section==0)
        {
            return "An example category with two buttons to demonstrate static categories."
        }
        return "These action categories are implemented in the Sample App. You can get details about implementing categories at the Apple developer site"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}


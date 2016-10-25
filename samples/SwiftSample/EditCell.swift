/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


import UIKit

class EditCell : UITableViewCell
{
    @IBOutlet weak var textField: UILabel?
    @IBOutlet weak var editField: KeyedTextField?
    @IBOutlet weak var selectField: UISegmentedControl?
}

class KeyedTextField: UITextField
{
    var key: String?
    var indexPath: IndexPath?
}

/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


import UIKit

class MainVC : UITableViewController
{
    @IBOutlet weak var version: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version!.text = MCESdk.sharedInstance().sdkVersion()
    }
}

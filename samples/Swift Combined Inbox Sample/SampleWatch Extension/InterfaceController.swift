/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var versionLabel: WKInterfaceLabel?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        versionLabel?.setText(MCEWatchSdk.sharedInstance().sdkVersion())
    }
}

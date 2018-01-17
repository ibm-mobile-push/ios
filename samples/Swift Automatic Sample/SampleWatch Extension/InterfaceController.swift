/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
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

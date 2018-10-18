/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import Foundation
import WatchKit

class RegistrationController: WKInterfaceController
{
    @IBOutlet weak var userIdLabel: WKInterfaceLabel?
    @IBOutlet weak var channelIdLabel: WKInterfaceLabel?
    @IBOutlet weak var appKeyLabel: WKInterfaceLabel?
    var observer: NSObjectProtocol?
    
    override func willDisappear() {
        super.willDisappear()
        if let observer = observer
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        updateRegistrationLabels()
        observer = NotificationCenter.default.addObserver(forName:   MCENotificationName.MCERegistered.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            self.updateRegistrationLabels()
        })
    }
    
    func updateRegistrationLabels()
    {
        guard let userIdLabel = userIdLabel else
        {
            return
        }
        guard let channelIdLabel = channelIdLabel else
        {
            return
        }
        guard let appKeyLabel = appKeyLabel else
        {
            return
        }
        
        if MCERegistrationDetails.shared.mceRegistered
        {
            userIdLabel.setText(MCERegistrationDetails.shared.userId)
            channelIdLabel.setText(MCERegistrationDetails.shared.channelId)
            appKeyLabel.setText(MCERegistrationDetails.shared.appKey)
        }        
    }
    
}


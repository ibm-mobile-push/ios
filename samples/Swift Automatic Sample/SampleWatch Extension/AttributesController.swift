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

class AttributesController: WKInterfaceController
{
    var listeners = [NSObjectProtocol]()
    var deleteTimer: Timer?
    var updateTimer: Timer?
    @IBOutlet weak var updateAttributeStatus: WKInterfaceLabel?
    @IBOutlet weak var deleteAttributeStatus: WKInterfaceLabel?
    
    @IBAction func updateAttribute(sender: Any) {
        updateAttributeStatus?.setText("Sending")
        updateAttributeStatus?.setTextColor(.white)
        MCEAttributesQueueManager.sharedInstance().updateUserAttributes(["onwatch": arc4random()])
    }
    
    @IBAction func deleteAttribute(sender: Any) {
        deleteAttributeStatus?.setText("Sending")
        deleteAttributeStatus?.setTextColor(.white)
        MCEAttributesQueueManager.sharedInstance().deleteUserAttributes(["onwatch"])
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        arc4random_stir()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        for listener in listeners {
            NotificationCenter.default.removeObserver(listener)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateUserAttributesError"), object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.updateAttributeStatus?.setText("Error")
                        self.updateAttributeStatus?.setTextColor(.red)
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateUserAttributesSuccess"), object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.updateAttributeStatus?.setText("Received")
                        self.updateAttributeStatus?.setTextColor(.green)
                        if let updateTimer = self.updateTimer
                        {
                            updateTimer.invalidate()
                        }
                        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.updateAttributeStatus?.setTextColor(.lightGray)
                            self.updateAttributeStatus?.setText("Idle")
                            self.updateTimer = nil
                        })
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("DeleteUserAttributesError"), object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.deleteAttributeStatus?.setText("Error")
                        self.deleteAttributeStatus?.setTextColor(.red)
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("DeleteUserAttributesSuccess"), object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let keys = userInfo["keys"] as? Array<String>
                {
                    if keys.index(of: "onwatch") != NSNotFound
                    {
                        self.deleteAttributeStatus?.setText("Received")
                        self.deleteAttributeStatus?.setTextColor(.green)
                        if let deleteTimer = self.deleteTimer
                        {
                            deleteTimer.invalidate()
                        }
                        self.deleteTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.deleteAttributeStatus?.setTextColor(.lightGray)
                            self.deleteAttributeStatus?.setText("Idle")
                            self.deleteTimer = nil
                        })
                    }
                }
            }
        }))
    }
}

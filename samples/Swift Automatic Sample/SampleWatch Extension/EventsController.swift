/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2017, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

import Foundation
import WatchKit

class EventsController: WKInterfaceController
{
    @IBOutlet weak var sendEventStatus: WKInterfaceLabel?
    @IBOutlet weak var queueEventStatus: WKInterfaceLabel?
    @IBOutlet weak var sendQueueStatus: WKInterfaceLabel?
    var listeners = [NSObjectProtocol]()
    var queueEventTimer: Timer?
    var sendEventTimer: Timer?
    var sendQueueTimer: Timer?
    
    @IBAction func sendEvent(sender: Any) {
        sendEventStatus?.setText("Sending")
        sendEventStatus?.setTextColor(.white)
        let event = MCEEvent(name: "watch", type: "watch", timestamp: nil, attributes: ["immediate": true])
        MCEEventService.sharedInstance().add(event, immediate: true)
    }
    
    @IBAction func queueEvent(sender: Any) {
        queueEventStatus?.setText("Queued")
        queueEventStatus?.setTextColor(.white)
        let event = MCEEvent(name: "watch", type: "watch", timestamp: nil, attributes: ["immediate": false])
        MCEEventService.sharedInstance().add(event, immediate: false)
    }
    
    @IBAction func sendQueue(sender: Any) {
        sendQueueStatus?.setText("Sending")
        sendQueueStatus?.setTextColor(.white)
        MCEEventService.sharedInstance().sendEvents()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        for listener in listeners {
            NotificationCenter.default.removeObserver(listener)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("MCEEventSuccess"), object: nil, queue: OperationQueue.main, using: { (note) in
            for event in note.userInfo?["events"] as! [MCEEvent]
            {
                if event.type == "watch" && event.name == "watch"
                {
                    self.sendQueueStatus?.setText("Received")
                    self.sendQueueStatus?.setTextColor(.green)
                    if let sendQueueTimer = self.sendQueueTimer
                    {
                        sendQueueTimer.invalidate()
                    }
                    self.sendQueueTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                        self.sendQueueStatus?.setText("Idle")
                        self.sendQueueStatus?.setTextColor(.lightGray)
                        self.sendQueueTimer = nil
                    })
                    
                    if event.attributes["immediate"] as! Bool
                    {
                        self.sendEventStatus?.setText("Received")
                        self.sendEventStatus?.setTextColor(.green)
                        if let sendEventTimer = self.sendEventTimer
                        {
                            sendEventTimer.invalidate()
                        }
                        self.sendEventTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.sendEventStatus?.setText("Idle")
                            self.sendEventStatus?.setTextColor(.lightGray)
                            self.sendEventTimer = nil
                        })
                    }
                    else
                    {
                        self.queueEventStatus?.setText("Received")
                        self.queueEventStatus?.setTextColor(.green)
                        if let queueEventTimer = self.queueEventTimer
                        {
                            queueEventTimer.invalidate()
                        }
                        self.queueEventTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.queueEventStatus?.setText("Idle")
                            self.queueEventStatus?.setTextColor(.lightGray)
                            self.queueEventTimer = nil
                        })
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: NSNotification.Name("MCEEventFailure"), object: nil, queue: OperationQueue.main, using: { (note) in
            
            for event in note.userInfo?["events"] as! [MCEEvent]
            {
                if event.type == "watch" && event.name == "watch"
                {
                    self.sendQueueStatus?.setText("Error")
                    self.sendQueueStatus?.setTextColor(.red)
                    if let sendQueueTimer = self.sendQueueTimer
                    {
                        sendQueueTimer.invalidate()
                    }
                    
                    if event.attributes["immediate"] as! Bool
                    {
                        self.sendEventStatus?.setText("Error")
                        self.sendEventStatus?.setTextColor(.red)
                        if let sendEventTimer = self.sendEventTimer
                        {
                            sendEventTimer.invalidate()
                        }
                    }
                    else
                    {
                        self.queueEventStatus?.setText("Error")
                        self.queueEventStatus?.setTextColor(.red)
                        if let queueEventTimer = self.queueEventTimer
                        {
                            queueEventTimer.invalidate()
                        }
                    }
                }
            }
        }))
    }
}

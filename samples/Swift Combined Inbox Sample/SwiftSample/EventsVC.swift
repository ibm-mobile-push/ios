/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum EventItems: Int
{
    case sendViaQueue
    case queueEvent
    case sendQueue
    
    static let count: Int = 3
}

class EventsVC : CellStatusTableViewController
{
    @objc func updateButtonsToReceived(note: NSNotification)
    {
        updateButtonsTo(newStatus: .recieved, events: note.userInfo!["events"] as! [MCEEvent])
    }
    @objc func updateButtonsToFailed(note: NSNotification)
    {
        updateButtonsTo(newStatus: .failed, events: note.userInfo!["events"] as! [MCEEvent])
    }
    func updateButtonsTo(newStatus: Status, events: [MCEEvent])
    {
        var found = false
        for event in events
        {
            if let reference = event.attributes["reference"] as? String
            {
                if(reference.isEqual("eventQueueEvent"))
                {
                    found=true
                    status["eventQueue"] = newStatus
                }
                if(reference.isEqual("addQueueEvent"))
                {
                    found=true
                    status["addQueue"] = newStatus
                }
            }
        }
        
        if(!found)
        {
            status["sendQueue"] = newStatus
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MCEEventSuccess"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MCEEventFailure"), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        status = [ "client": .normal, "eventQueue": .normal, "addQueue": .normal, "sendQueue": .normal ]

        NotificationCenter.default.addObserver(self, selector: #selector(EventsVC.updateButtonsToReceived(note:)), name: NSNotification.Name("MCEEventSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsVC.updateButtonsToFailed(note:)), name: NSNotification.Name("MCEEventFailure"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "view", for: indexPath as IndexPath)
        
        if let eventItem = EventItems(rawValue: indexPath.item)
        {
            switch(eventItem)
            {
            case .sendViaQueue:
                cell.textLabel!.text="Send Event Via Queue"
                cellStatus(cell: cell, key: "eventQueue")
                break
            case .queueEvent:
                cell.textLabel!.text="Queue an Event"
                cellStatus(cell: cell, key: "addQueue")
                break
            case .sendQueue:
                cell.textLabel!.text="Send Queued Events"
                cellStatus(cell: cell, key: "sendQueue")
                break
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return EventItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        return "Click to send a test event, you should see the send status to the right of the click event."
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Events"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if let eventItem = EventItems(rawValue: indexPath.item)
        {
            switch(eventItem)
            {
            case .sendViaQueue:
                let event = MCEEvent.init()
                event.fromDictionary(["name" : "appOpened", "type": "simpleNotification", "timestamp": NSDate.init(), "attributes": ["reference": "eventQueueEvent"]])
                MCEEventService.sharedInstance().add(event, immediate: true)
                status["sendQueue"] = .sent
                DispatchQueue.main.async(execute: { () -> Void in
                    tableView.reloadData()
                })
                break
            case .queueEvent:
                let event = MCEEvent.init()
                event.fromDictionary(["name" : "appOpened", "type": "simpleNotification", "timestamp": NSDate.init(), "attributes": ["reference": "addQueueEvent"]])
                MCEEventService.sharedInstance().add(event, immediate: false)
                status["addQueue"] = .queued
                DispatchQueue.main.async(execute: { () -> Void in
                    tableView.reloadData()
                })

                break
            case .sendQueue:
                MCEEventService.sharedInstance().sendEvents()
                status["sendQueue"] = .sent
                DispatchQueue.main.async(execute: { () -> Void in
                    tableView.reloadData()
                })

                break
            }
        }
    }
}

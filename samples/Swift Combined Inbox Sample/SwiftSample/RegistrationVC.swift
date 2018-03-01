/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum RegistrationItems: Int
{
    case UserId
    case ChannelId
    case AppKey
    case Registration
    
    static let count: Int = 4
}

class RegistrationVC : UITableViewController
{
    var observer: AnyObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("MCERegisteredNotification"), object: nil, queue: OperationQueue.main, using: { (notification: Notification) -> Void in
            self.refresh(sender: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
    
    @IBAction func refresh(sender: AnyObject?) {
        if let s = sender
        {
            s.endRefreshing()
        }
        tableView.reloadRows(at: [IndexPath(item: 3, section: 0), IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "view", for: indexPath as IndexPath)
        
        if let registrationItem = RegistrationItems(rawValue: indexPath.item)
        {
            switch(registrationItem)
            {
            case .UserId:
                cell.textLabel!.text = "User Id"
                cell.detailTextLabel!.text = MCERegistrationDetails.sharedInstance().userId
                break
            case .ChannelId:
                cell.textLabel!.text = "Channel Id"
                cell.detailTextLabel!.text = MCERegistrationDetails.sharedInstance().channelId
                break
            case .AppKey:
                cell.textLabel!.text = "App Key"
                cell.detailTextLabel!.text = MCERegistrationDetails.sharedInstance().appKey
                break
            case .Registration:
                cell.textLabel!.text = "Registration"
                if MCERegistrationDetails.sharedInstance().mceRegistered
                {
                    cell.detailTextLabel!.text = "Registered"
                }
                else
                {
                    cell.detailTextLabel!.text = "Click to start"
                }
                
                break
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RegistrationItems.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Credentials"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        return "User ID and Channel ID are known only after registration. The registration process could take several minutes. If you have have issues with registering a device, make sure you have the correct certificate and appKey."
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if indexPath.item == 3
        {
            if !MCERegistrationDetails.sharedInstance().mceRegistered
            {
                MCESdk.sharedInstance().manualInitialization()
            }
        }
    }
}



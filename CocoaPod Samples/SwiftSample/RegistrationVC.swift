/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum RegistrationItems: Int
{
    case UserId
    case ChannelId
    case AppKey
    
    static let count: Int = 3
}

class RegistrationVC : UITableViewController
{
    var observer: AnyObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("RegisteredNotification"), object: nil, queue: OperationQueue.main, using: { (notification: Notification) -> Void in
            self.refresh(sender: nil)
        })
    }
    
    deinit {
        if let ob = observer
        {
            NotificationCenter.default.removeObserver(ob)
        }
    }
    
    func refresh(sender: AnyObject?) {
        if let s = sender
        {
            s.endRefreshing()
        }
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)], with: .automatic)
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
                cell.detailTextLabel!.text = MCERegistrationDetails.userId()
                break
            case .ChannelId:
                cell.textLabel!.text = "Channel Id"
                cell.detailTextLabel!.text = MCERegistrationDetails.channelId()
                break
            case .AppKey:
                let config = MCESdk.sharedInstance().config
                cell.textLabel!.text = "App Key"
                cell.detailTextLabel!.text = config?.appKey
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
    }
}

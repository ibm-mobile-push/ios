/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


import UIKit

class MainVC : UITableViewController, UIViewControllerPreviewingDelegate
{
    @IBOutlet weak var version: UILabel?
    @IBOutlet weak var inboxCell: UITableViewCell?
    @IBOutlet weak var altInboxCell: UITableViewCell?
    
    var previewingContext: UIViewControllerPreviewing?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inboxUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version!.text = MCESdk.sharedInstance().sdkVersion()
        if #available(iOS 9.0, *) {
            self.previewingContext = self.registerForPreviewing(with: self, sourceView: self.view)
        }
        
        // Show Inbox counts on main page
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.inboxUpdate), name: NSNotification.Name("MCESyncDatabase"), object: nil)
        if(MCERegistrationDetails.sharedInstance().mceRegistered)
        {
            MCEInboxQueueManager.sharedInstance().syncInbox()
        }
        else
        {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("MCERegisteredNotification"), object: nil, queue: .main, using: { (note) in
                MCEInboxQueueManager.sharedInstance().syncInbox()
            })
        }
    }
    
    // Show Inbox counts on main page
    @objc func inboxUpdate()
    {
        guard let messages = MCEInboxDatabase.sharedInstance().inboxMessagesAscending(true) as? Array<MCEInboxMessage> else { return }
        var unreadCount=0
        for message in messages
        {
            if !message.isRead
            {
                unreadCount += 1
            }
        }
        
        var subtitle = ""
        if MCERegistrationDetails.sharedInstance().mceRegistered
        {
            subtitle = "\(messages.count) messages, \(unreadCount) unread"
        }
        
        DispatchQueue.main.async {
            self.inboxCell?.detailTextLabel?.text = subtitle
            self.altInboxCell?.detailTextLabel?.text = subtitle
            self.tableView.reloadData()
        }
    }
    
    @available(iOS 9.0, *)
    func isForceTouchAvailable() -> Bool
    {
        if self.traitCollection.responds(to: #selector(getter: UITraitCollection.forceTouchCapability))
        {
            return self.traitCollection.forceTouchCapability == UIForceTouchCapability.available
        }
        return false
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let cellPosition = self.tableView.convert(location, from: self.view)
        if let path = self.tableView.indexPathForRow(at: cellPosition)
        {
            if let tableCell = self.tableView.cellForRow(at: path)
            {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                if let ident = tableCell.restorationIdentifier
                {
                    let previewController = storyboard.instantiateViewController(withIdentifier: ident)
                    previewingContext.sourceRect = self.view.convert(tableCell.frame, from: self.tableView)
                    return previewController
                }
            }
        }
        return nil
    }
}



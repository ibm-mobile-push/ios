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
        version!.text = MCESdk.shared.sdkVersion()
        if #available(iOS 9.0, *) {
            self.previewingContext = self.registerForPreviewing(with: self, sourceView: self.view)
        }
        
        // Show Inbox counts on main page
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.inboxUpdate), name: MCENotificationName.InboxCountUpdate.rawValue, object: nil)
        if(MCERegistrationDetails.shared.mceRegistered)
        {
            MCEInboxQueueManager.shared.syncInbox()
        }
        else
        {
            NotificationCenter.default.addObserver(forName: MCENotificationName.MCERegistered.rawValue, object: nil, queue: .main, using: { (note) in
                MCEInboxQueueManager.shared.syncInbox()
            })
        }
    }
    
    // Show Inbox counts on main page
    @objc func inboxUpdate()
    {
        let unreadCount = MCEInboxDatabase.shared.unreadMessageCount()
        let messageCount = MCEInboxDatabase.shared.messageCount()
        
        var subtitle = ""
        if MCERegistrationDetails.shared.mceRegistered
        {
            subtitle = "\(messageCount) messages, \(unreadCount) unread"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let identifier = cell?.accessibilityIdentifier else {
            print("Couldn't determine view controller to show!")
            return
        }
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Couldn't find view controller to show")
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            splitViewController?.showDetailViewController(navigationController, sender: self)
        } else {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}



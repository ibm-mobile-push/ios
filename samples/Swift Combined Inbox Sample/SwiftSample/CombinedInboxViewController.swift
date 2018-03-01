/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

// This is the class that provides a merged view of the MCEInbox and another database of messages. If you're using a different database, you will need to return your message type, update messageDate (assuming your message types have dates), and get the list of messages of your message type. You could merge this code into your existing view controller, and use code like what is in refreshMessages to merge the MCEInbox messages with your existing messages.

import UIKit

class CombinedInboxViewController: UITableViewController {
    var allMessages = [AnyHashable]()
    var mceObserver: NSObjectProtocol? = nil
    var customObserver: NSObjectProtocol? = nil
    
    // Utility for ease of sorting
    func messageDate(message: AnyHashable) -> Date {
        if let message = message as? MCEInboxMessage {
            return message.sendDate
        } else if let message = message as? CustomMessage {
            return message.pubDate
        } else {
            return Date.distantPast
        }
    }
    
    @objc func refreshMessages() {
        
        var allMessagesSet = Set<AnyHashable>()
        
        if let inboxMessages = MCEInboxDatabase.sharedInstance().inboxMessagesAscending(true) as? [AnyHashable] {
            allMessagesSet.formUnion(inboxMessages)
        } else {
            print("Couldn't fetch inbox messages")
        }

        allMessagesSet.formUnion(CustomInboxDatabase.shared.messages )

        // Sort by date
        allMessages = Array<AnyHashable>(allMessagesSet).sorted(by: { (lhs, rhs) -> Bool in
            return messageDate(message: lhs) > messageDate(message: rhs)
        })
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func viewController(forIndexPath indexPath: IndexPath) -> UIViewController? {
        var viewController: UIViewController? = nil
        let message = allMessages[indexPath.item]
        if let inboxMessage = message as? MCEInboxMessage, let templateHandler = MCETemplateRegistry.sharedInstance().handler(forTemplate: inboxMessage.templateName) {
            if let displayViewController = templateHandler.displayViewController() {
                if templateHandler.shouldDisplay(inboxMessage) {
                    inboxMessage.isRead = true
                    MCEEventService.sharedInstance().recordView(for: inboxMessage, attribution: inboxMessage.attribution, mailingId: inboxMessage.mailingId)
                    displayViewController.inboxMessage = inboxMessage
                    displayViewController.setContent()
                    viewController = displayViewController as? UIViewController
                } else {
                    print("\(inboxMessage.templateName) template says the message should not be opened.")
                }
            } else {
                print("\(inboxMessage.templateName) template requested but not registered")
            }
            
        } else if let customMessage = message as? CustomMessage, let storyboard = storyboard, let customViewController =
            storyboard.instantiateViewController(withIdentifier: "customMessage") as? CustomMessageViewController {
            customViewController.customMessage = customMessage
            customMessage.isRead = true
            CustomInboxDatabase.shared.updateCustomMessageStatus(customMessage: customMessage)
            viewController = customViewController
        }
        
        if let viewController = viewController {
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target:nil, action: nil)
            spaceButton.width = 10
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMessage))
            let nextButton = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-down"), style: .plain, target: self, action: #selector(nextMessage))
            if indexPath.row == allMessages.count - 1 {
                nextButton.isEnabled = false
            }
            let prevButton = UIBarButtonItem(image: #imageLiteral(resourceName: "chevron-up"), style: .plain, target: self, action: #selector(previousMessage))
            if indexPath.row == 0 {
                prevButton.isEnabled = false
            }
            viewController.navigationItem.rightBarButtonItems = [nextButton, prevButton, spaceButton, deleteButton]
        }
        
        return viewController
    }

    @objc func deleteMessage(_ sender: Any?) {
        if let viewController = navigationController?.topViewController as? CustomMessageViewController {
            if let customMessage = viewController.customMessage {
                customMessage.isDeleted = true
                CustomInboxDatabase.shared.updateCustomMessageStatus(customMessage: customMessage)
                refreshMessages()
                navigationController?.popViewController(animated: true)
            }
        } else if let viewController = navigationController?.topViewController as? MCETemplateDisplay {
            let inboxMessage = viewController.inboxMessage
            inboxMessage?.isDeleted = true
            refreshMessages()
            navigationController?.popViewController(animated: true)
        } else {
            print("Couldn't determine the top view controller")
        }
    }
    
    @objc func previousMessage(sender: UIBarButtonItem) {
        guard let navigationController = navigationController else { return }
        var indexPath: IndexPath? = nil
        if let viewController = navigationController.topViewController as? CustomMessageViewController {
            if let customMessage = viewController.customMessage {
                if let index = allMessages.index(of: customMessage) {
                    indexPath = IndexPath(item: index-1, section: 0)
                }
            }
        } else if let viewController = navigationController.topViewController as? MCETemplateDisplay {
            if let index = allMessages.index(of: viewController.inboxMessage) {
                indexPath = IndexPath(item: index-1, section: 0)
            }
        } else {
            print("Couldn't determine the top view controller")
        }
        
        if let indexPath = indexPath, let viewController = self.viewController(forIndexPath: indexPath) {
            var viewControllers = navigationController.viewControllers
            viewControllers.removeLast()
            viewControllers.append(viewController)
            navigationController.setViewControllers(viewControllers, animated: true)
        }
    }
    
    @objc func nextMessage(sender: UIBarButtonItem) {
        guard let navigationController = navigationController else { return }
        var indexPath: IndexPath? = nil
        if let viewController = navigationController.topViewController as? CustomMessageViewController {
            if let customMessage = viewController.customMessage {
                if let index = allMessages.index(of: customMessage) {
                    indexPath = IndexPath(item: index+1, section: 0)
                }
            }
        } else if let viewController = navigationController.topViewController as? MCETemplateDisplay {
            if let index = allMessages.index(of: viewController.inboxMessage) {
                indexPath = IndexPath(item: index+1, section: 0)
            }
        } else {
            print("Couldn't determine the top view controller")
        }
        
        if let indexPath = indexPath, let viewController = self.viewController(forIndexPath: indexPath) {
            var viewControllers = navigationController.viewControllers
            viewControllers.removeLast()
            viewControllers.append(viewController)
            navigationController.setViewControllers(viewControllers, animated: true)
        }
    }
}

private typealias DataSource = CombinedInboxViewController
extension DataSource {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
}

private typealias Delegate = CombinedInboxViewController
extension Delegate {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = allMessages[indexPath.item]
        if let inboxMessage = message as? MCEInboxMessage, let template = MCETemplateRegistry.sharedInstance().handler(forTemplate: inboxMessage.templateName) {
            return template.cell(for: tableView, inboxMessage: inboxMessage, indexPath: indexPath)
        } else if let customMessage = message as? CustomMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rss", for: indexPath)
            cell.textLabel?.font = customMessage.isRead ? UIFont.systemFont(ofSize: UIFont.labelFontSize) : UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
            cell.textLabel?.text = customMessage.title
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.detailTextLabel?.text = formatter.string(from: customMessage.pubDate)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = allMessages[indexPath.row]
        if let inboxMessage = message as? MCEInboxMessage, let template = MCETemplateRegistry.sharedInstance().handler(forTemplate: inboxMessage.templateName) {
            return CGFloat(template.tableView(tableView, heightForRowAt: indexPath, inboxMessage: inboxMessage))
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let viewController = viewController(forIndexPath: indexPath) {
            navigationController?.pushViewController(viewController, animated: true)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let message = allMessages[indexPath.item]
        
        if let inboxMessage = message as? MCEInboxMessage {
            
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                inboxMessage.isDeleted = true
                self.refreshMessages()
            }
            
            let readTitle: String = inboxMessage.isRead ? "Mark as Unread" : "Mark as Read"
            let readAction = UITableViewRowAction(style: .destructive, title: readTitle) { (action, indexPath) in
                inboxMessage.isRead = !inboxMessage.isRead
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return [deleteAction, readAction]
        } else if let customMessage = message as? CustomMessage {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                customMessage.isDeleted = true
                CustomInboxDatabase.shared.updateCustomMessageStatus(customMessage: customMessage)
                self.refreshMessages()
            }
            return [deleteAction]
        }
        
        return nil
    }
}

private typealias ViewLifeCycle = CombinedInboxViewController
extension ViewLifeCycle {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            MCEInboxQueueManager.sharedInstance().syncInbox()
        }

        customObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("CustomInboxDatabaseUpdate"), object: nil, queue: OperationQueue.main, using: { (note) in
            self.refreshMessages()
        })
        
        mceObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("MCESyncDatabase"), object: nil, queue: OperationQueue.main) { (note) in
            if note.userInfo == nil || note.userInfo!["error"] == nil {
                self.refreshMessages()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let customObserver = customObserver {
            NotificationCenter.default.removeObserver(customObserver)
            self.customObserver = nil
        }

        if let mceObserver = mceObserver {
            NotificationCenter.default.removeObserver(mceObserver)
            self.mceObserver = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        refreshMessages()
    }
}

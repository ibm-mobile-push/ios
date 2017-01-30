/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit

enum Status
{
    case normal
    case sent
    case failed
    case recieved
    case queued
}

class CellStatusTableViewController: UITableViewController
{
    var status: [String:Status] = ["fake": .normal]
    
    func normalCellStatus(cell: UITableViewCell, key: String, afterDelay: Double)
    {        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                self.status[key] = .normal
                self.tableView.reloadData()
        }
    }
    
    func cellStatus(cell: UITableViewCell, key: String)
    {
        switch(status[key]!)
        {
        case .sent:
            cell.detailTextLabel!.text="Sending"
            status[key] = .normal
            break
        case .recieved:
            cell.detailTextLabel!.text = "Received"
            normalCellStatus(cell: cell, key: key, afterDelay: 5)
            break
        case .failed:
            cell.detailTextLabel!.text = "Failed"
            normalCellStatus(cell: cell, key: key, afterDelay: 5)
            break
        default:
            cell.detailTextLabel!.text = ""
            break
        }
    }
}

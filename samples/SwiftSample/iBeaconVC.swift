/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import Foundation

class iBeaconVC: UITableViewController {
    var beaconRegions = [CLBeaconRegion]()
    var beaconStatus = [NSNumber:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beaconRegions = MCELocationDatabase.sharedInstance().beaconRegions().sortedArray(using: [ NSSortDescriptor(key: "major", ascending: true) ]) as! [CLBeaconRegion]
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: EnteredBeacon), object: nil, queue: OperationQueue.main) {
            notification in
            self.beaconStatus[notification.userInfo!["major"] as! NSNumber] = String.init(format: "Entered Minor %@", notification.userInfo!["minor"] as! NSNumber)
            self.tableView.reloadData()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: ExitedBeacon), object: nil, queue: OperationQueue.main) {
            notification in
            self.beaconStatus[notification.userInfo!["major"] as! NSNumber] = String.init(format: "Exited Minor %@", notification.userInfo!["minor"] as! NSNumber)
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: LocationDatabaseUpdated), object: nil, queue: OperationQueue.main)
        {
            notification in
            self.beaconRegions = MCELocationDatabase.sharedInstance().beaconRegions().sortedArray(using: [ NSSortDescriptor(key: "major", ascending: true) ]) as! [CLBeaconRegion]
            self.tableView.reloadData()
        }

    }
    
    @IBAction func refresh(sender: AnyObject)
    {
        MCELocationClient().scheduleSync()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let vertical = tableView.dequeueReusableCell(withIdentifier: "vertical", for: indexPath)
            let config = MCESdk.sharedInstance().config;
            if(indexPath.item==0)
            {
                vertical.textLabel!.text = "UUID"
                vertical.detailTextLabel!.text = config?.beaconUUID.uuidString
                vertical.detailTextLabel!.textColor = UIColor.black
            }
            else
            {
                vertical.textLabel!.text = "Status"
                if(config!.beaconEnabled)
                {
                    vertical.detailTextLabel!.text = "ENABLED"
                    vertical.detailTextLabel!.textColor = UIColor.green
                }
                else
                {
                    vertical.detailTextLabel!.text = "DISABLED"
                    vertical.detailTextLabel!.textColor = UIColor.red
                }
            }
            return vertical;
        }
        
        let basic = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        let major = self.beaconRegions[indexPath.item].major
        basic.textLabel!.text = String(format: "%@", major!)
        if(self.beaconStatus[major!] != nil)
        {
            basic.detailTextLabel!.text = self.beaconStatus[major!]
        }
        else
        {
            basic.detailTextLabel!.text = ""
        }
        
        return basic
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0)
        {
            return 2
        }
        return self.beaconRegions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section==0)
        {
            return "iBeacon Feature"
        }
        return "iBeacon Major Regions"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

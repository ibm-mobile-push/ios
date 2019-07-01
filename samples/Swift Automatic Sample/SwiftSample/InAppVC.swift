/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


let BOTTOM_BANNER_ITEM=0
let TOP_BANNER_ITEM=1
let IMAGE_ITEM=2
let VIDEO_ITEM=3
let NEXT_ITEM=4

let BACKGROUND_SECTION=0
let EXECUTE_SECTION=1
let CANNED_SECTION=2

import UIKit

class InAppVC : UITableViewController, MCEActionProtocol
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section==0
        {
            return 50
        }
        return 34
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:height))
        let label = UILabel(frame: CGRect(x:10, y:height - 16 - 3, width:tableView.frame.size.width-20, height:16))
        view.addSubview(label)
        
        if tableView.layer.contents == nil
        {
            view.backgroundColor = UIColor.clear
            label.textColor = UIColor.gray
            label.font = UIFont.systemFont(ofSize: 13)
        }
        else
        {
            view.backgroundColor = UIColor(white: 0, alpha: 0.2)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 13)
        }
        
        switch(section)
        {
        case BACKGROUND_SECTION:
            label.text = "Toggle Background"
            break
        case EXECUTE_SECTION:
            label.text = "Execute InApp"
            break
        case CANNED_SECTION:
            label.text = "Add Canned InApp"
            break
        default:
            break
        }
        label.text = label.text?.uppercased()
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        if tableView.layer.contents == nil
        {
            cell.backgroundColor = UIColor.white
            cell.textLabel!.textColor = UIColor.black
        }
        else
        {
            cell.backgroundColor = UIColor(white: 0, alpha: 0.2)
            cell.textLabel!.textColor = UIColor.white
        }
        
        switch(indexPath.section)
        {
        case BACKGROUND_SECTION:
            cell.textLabel!.text = "Toggle background image"
            break
        default:
            switch(indexPath.item)
            {
            case TOP_BANNER_ITEM:
                cell.textLabel!.text = "Top Banner Template"
                break
            case BOTTOM_BANNER_ITEM:
                cell.textLabel!.text = "Bottom Banner Template"
                break
            case IMAGE_ITEM:
                cell.textLabel!.text = "Image Template"
                break
            case VIDEO_ITEM:
                cell.textLabel!.text = "Video Template"
                break
            case NEXT_ITEM:
                cell.textLabel!.text = "Next Queued Template"
                break
            default:
                break
            }
            break
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MCEInboxQueueManager.shared.syncInbox()
        MCEActionRegistry.shared.registerTarget(self, with: #selector(self.displayVideo(userInfo:)), forAction: "showVideo")
        MCEActionRegistry.shared.registerTarget(self, with: #selector(self.displayTopBanner(userInfo:)), forAction: "showTopBanner")
        MCEActionRegistry.shared.registerTarget(self, with: #selector(self.displayBottomBanner(userInfo:)), forAction: "showBottomBanner")
        MCEActionRegistry.shared.registerTarget(self, with: #selector(self.displayImage(userInfo:)), forAction: "showImage")
    }
    
    @objc func displayVideo(userInfo: NSDictionary?)
    {
        MCEInAppManager.shared.executeRule(["video"])
    }
    
    @objc func displayTopBanner(userInfo: NSDictionary?)
    {
        MCEInAppManager.shared.executeRule(["topBanner"])
    }
    
    @objc func displayBottomBanner(userInfo: NSDictionary?)
    {
        MCEInAppManager.shared.executeRule(["bottomBanner"])
    }
    
    @objc func displayImage(userInfo: NSDictionary?)
    {
        MCEInAppManager.shared.executeRule(["image"])
    }
    
    func displayNext(userInfo: NSDictionary?)
    {
        MCEInAppManager.shared.executeRule(["all"])
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        switch(section)
        {
        case BACKGROUND_SECTION:
            return 1
        case EXECUTE_SECTION:
            return 5
        case CANNED_SECTION:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch(indexPath.section)
        {
        case BACKGROUND_SECTION:
            if tableView.layer.contents==nil
            {
                let image = UIImage(named: "background.jpg")!.cgImage
                tableView.layer.contents = image
            }
            else
            {
                tableView.layer.contents = nil
            }
            tableView.layer.contentsGravity = CALayerContentsGravity.resizeAspectFill
            tableView.reloadData()
            break
        case EXECUTE_SECTION:
            switch(indexPath.item)
            {
            case TOP_BANNER_ITEM:
                self.displayTopBanner(userInfo: nil)
                break
            case BOTTOM_BANNER_ITEM:
                self.displayBottomBanner(userInfo: nil)
                break
            case IMAGE_ITEM:
                self.displayImage(userInfo: nil)
                break
            case VIDEO_ITEM:
                self.displayVideo(userInfo: nil)
                break
            case NEXT_ITEM:
                self.displayNext(userInfo: nil)
                break
            default:
                break
            }
            break
        case CANNED_SECTION:
            var userInfo: [AnyHashable : Any] = Dictionary()
            guard let past = MCEApiUtil.date(toIso8601Format: NSDate.distantPast) else {
                print("Couldn't create distant past ISO 8601 string");
                return
            }
            guard let future = MCEApiUtil.date(toIso8601Format: NSDate.distantFuture) else {
                print("Couldn't create distant future ISO 8601 string");
                return
            }
            switch(indexPath.item)
            {
            case TOP_BANNER_ITEM:
                userInfo = [
                    "inApp":[
                        "rules":["topBanner", "all"],
                        "maxViews": 5,
                        "template": "default",
                        "content": [
                            "orientation": "top",
                            "action": [
                                "type":"url",
                                "value":"http://ibm.co"
                            ],
                            "text": "Canned Banner Template Text",
                            "icon": "note",
                            "color": "0077ff"
                        ],
                        "triggerDate": past,
                        "expriationDate": future
                    ]
                ]
                break
            case BOTTOM_BANNER_ITEM:
                userInfo = [
                    "notification-action":["type":"showBottomBanner"],
                    "inApp":[
                        "rules":["bottomBanner", "all"],
                        "maxViews": 5,
                        "template": "default",
                        "content": [
                            "action": [
                                "type":"url",
                                "value":"http://ibm.co"
                            ],
                            "text": "Canned Banner Template Text",
                            "icon": "note",
                            "color": "0077ff"
                        ],
                        "triggerDate": past,
                        "expriationDate": future
                    ]
                ]
                break
            case IMAGE_ITEM:
                userInfo = [
                    "notification-action":["type":"showImage"],
                    "inApp":[
                        "rules":["image", "all"],
                        "maxViews": 5,
                        "template": "image",
                        "content": [
                            "action": [
                                "type":"url",
                                "value":"http://ibm.co"
                            ],
                            "title": "Canned Image Template Text",
                            "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt.",
                            "image": "https://www.ibm.com/us-en/images/homepage/leadspace/01172016_ls_dynamic-pricing-announcement_bg_14018_2732x1300.jpg"
                        ],
                        "triggerDate": past,
                        "expriationDate": future
                    ]
                ]
                break
            case VIDEO_ITEM:
                userInfo = [
                    "inApp":[
                        "rules":["video", "all"],
                        "maxViews": 5,
                        "template": "video",
                        "content": [
                            "action": [
                                "type":"url",
                                "value":"http://ibm.co"
                            ],
                            "title": "Canned Image Template Text",
                            "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque rhoncus, eros sed imperdiet finibus, purus nibh placerat leo, non fringilla massa tortor in tellus. Donec aliquet pharetra dui ac tincidunt. Ut eu mi at ligula varius suscipit. Vivamus quis quam nec urna sollicitudin egestas eu at elit. Nulla interdum non ligula in lobortis. Praesent lobortis justo at cursus molestie. Aliquam lectus velit, elementum non laoreet vitae, blandit tempus metus. Nam ultricies arcu vel lorem cursus aliquam. Nunc eget tincidunt ligula, quis suscipit libero. Integer velit nisi, lobortis at malesuada at, dictum vel nisi. Ut vulputate nunc mauris, nec porta nisi dignissim ac. Sed ut ante sapien. Quisque tempus felis id maximus congue. Aliquam quam eros, congue at augue et, varius scelerisque leo. Vivamus sed hendrerit erat. Mauris quis lacus sapien. Nullam elit quam, porttitor non nisl et, posuere volutpat enim. Praesent euismod at lorem et vulputate. Maecenas fermentum odio non arcu iaculis egestas. Praesent et augue quis neque elementum tincidunt.",
                            "video":"http://techslides.com/demos/sample-videos/small.mp4"
                        ],
                        "triggerDate": past,
                        "expriationDate": future
                    ]
                ]
                break
            default:
                break
            }
            
            MCEInAppManager.shared.processPayload(userInfo)
            break
        default:
            break
        }
    }
}

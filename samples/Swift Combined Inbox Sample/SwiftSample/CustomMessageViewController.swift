/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit
import WebKit

// This is a view controller for a custom message object. Use yours instead.

class CustomMessageViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionView: WKWebView?
    @IBOutlet weak var categoryLabel: UILabel?
    @IBOutlet weak var pubDateLabel: UILabel?
    
    @IBAction func clickedLinkButton() {
        if let customMessage = customMessage {
            UIApplication.shared.openURL(customMessage.link)
        }
    }
    
    var customMessage: CustomMessage? { didSet { update() } }
    
    override func viewDidLoad() {
        update()
    }
    
    func update() {
        if let customMessage = customMessage {
            titleLabel?.text = customMessage.title
            descriptionView?.loadHTMLString("""
                <html>
                <head>
                <style>
                body {
                margin: 0;
                padding: 0;
                font-family: '-apple-system', 'HelveticaNeue';
                font-size: 110%;
                border-top: 1px solid rgb(219, 219, 219);
                padding-top: 10px;
                }
                </style>
                </head>
                <body>
                \(customMessage.description)
                </body>
                </html>
                """, baseURL: nil)
            
            categoryLabel?.text = customMessage.category
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            pubDateLabel?.text = formatter.string(from: customMessage.pubDate)
        }
    }
}

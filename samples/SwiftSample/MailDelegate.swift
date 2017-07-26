/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


import UIKit
import MessageUI

class MailDelegate : NSObject, MFMailComposeViewControllerDelegate, MCEActionProtocol
{
    var mailController: MFMailComposeViewController?
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch(result)
        {
        case .cancelled:
            print("Mail send was canceled")
            break
        case .saved:
            print("Mail was saved as draft")
            break
        case .sent:
            print("Mail was sent")
            break
        case .failed:
            print("Mail send failed")
            break
        }
        controller.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    func sendEmail(action: NSDictionary)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            print("Custom action with value \(action["value"])")
            if !MFMailComposeViewController.canSendMail()
            {
                UIAlertView.init(title: "Cannot send mail", message: "Please verify that you have a mail account setup.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
                return
            }
            
            if let value = action["value"] as? NSDictionary
            {
                let subject = value["subject"] as! String?
                let body = value["body"] as! String?
                let recipient = value["recipient"] as! String?
                
                if subject != nil && body != nil && recipient != nil
                {
                    self.mailController = MFMailComposeViewController.init()
                    self.mailController!.mailComposeDelegate=self
                    self.mailController!.setSubject(subject!)
                    self.mailController!.setToRecipients([recipient!])
                    self.mailController!.setMessageBody(body!, isHTML: false)
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(self.mailController!, animated: true, completion: { () -> Void in
                    })
                    return
                }
            }
            
            UIAlertView.init(title: "Cannot send mail", message: "Incorrect package contents.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
            
        }
    }
    
}

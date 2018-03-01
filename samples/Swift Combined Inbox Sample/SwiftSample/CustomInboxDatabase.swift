/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

// This is a sample inbox database. It uses SQLite.swift. If you have already defined another database already, use it instead.

import Foundation
import SQLite

class CustomInboxDatabase {
    
    static let shared = CustomInboxDatabase()
    var messages = Set<AnyHashable>()
    var feedParser: FeedParser? = nil
    lazy var db: Connection? = {
        let filename = "\(NSHomeDirectory())/Library/customInbox.sqlite"
        do {
            return try Connection(filename)
        } catch {
            print("Couldn't create connection \(error)")
        }
        return nil
    }()
    
    private init() {
        feedParser = FeedParser(delegate: self)
        
        if let db = db {
            do {
                try CustomMessage.createTable(db: db)
                messages.formUnion(try CustomMessage.allCustomMessages(db: db))
            } catch {
                print("Couldn't create custom message table \(error)")
            }
        } else {
            print("Couldn't create custom message database")
        }
    }
    
    func updateCustomMessageStatus(customMessage: CustomMessage) {
        if let db = db {
            do {
                try customMessage.updateStatus(db: db)
                if customMessage.isDeleted {
                    messages.remove(customMessage)
                }
            } catch {
                print("Couldn't update custom message \(error)")
            }

        } else {
            print("Couldn't create custom message database")
        }
    }
    
    func parsedCustomMessage(customMessage: CustomMessage) {
        var customMessage = customMessage
        if let db = db {
            do {
                try customMessage.verify(db: db)
            } catch {
                print("Couldn't verify custom message \(error)")
            }
        } else {
            print("Couldn't create custom message database")
        }

        if customMessage.isDeleted == false {
            messages.insert(customMessage)
        }
    }
    
    func parserComplete() {
        NotificationCenter.default.post(name: NSNotification.Name("CustomInboxDatabaseUpdate"), object: nil)
    }
}

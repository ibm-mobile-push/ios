/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

// This is an example message object. Use yours instead.

import Foundation
import SQLite

private struct Columns {
    let id = Expression<Int64>("id")
    let title = Expression<String>("title")
    let link = Expression<String>("link")
    let description = Expression<String>("description")
    let category = Expression<String>("category")
    let pubDate = Expression<Date>("pubDate")
    let isRead = Expression<Bool>("isRead")
    let isDeleted = Expression<Bool>("isDeleted")
}

class CustomMessage {
    var rowid: Int64? = nil
    let title: String
    let link: URL
    let description: String
    let category: String
    let pubDate: Date
    var isRead: Bool = false
    var isDeleted: Bool = false
    
    static let table = Table("CustomMessages")
    fileprivate static let columns = Columns()
    static func createTable(db: Connection) throws {
        try db.run(table.create(ifNotExists: true) { t in
            t.column(columns.id, primaryKey: true)
            t.column(columns.title)
            t.column(columns.link, unique: true)
            t.column(columns.description)
            t.column(columns.category)
            t.column(columns.pubDate)
            t.column(columns.isRead)
            t.column(columns.isDeleted)
        })
    }
    
    init?(row: Row) {
        self.rowid = row[CustomMessage.columns.id]
        guard let link = URL(string: row[CustomMessage.columns.link])
            else { return nil }
        self.title = row[CustomMessage.columns.title]
        self.link = link
        self.description = row[CustomMessage.columns.description]
        self.category = row[CustomMessage.columns.category]
        self.pubDate = row[CustomMessage.columns.pubDate]
        self.isRead = row[CustomMessage.columns.isRead]
        self.isDeleted = row[CustomMessage.columns.isDeleted]
    }
    
    static func allCustomMessages(db: Connection) throws -> Set<AnyHashable> {
        var allMessages = Set<CustomMessage>()
        for row in try db.prepare(table) {
            if let message = CustomMessage(row: row), message.isDeleted == false {
                allMessages.insert(message)
            }
        }
        return allMessages
    }
    
    init(title: String, link: URL, description: String, category: String, pubDate: Date) {
        self.title = title
        self.link = link
        self.description = description
        self.category = category
        self.pubDate = pubDate
    }
    
    func updateStatus(db: Connection) throws {
        guard let rowid = rowid else { return }
        try db.run(CustomMessage.table.filter(CustomMessage.columns.id == rowid).update(
            CustomMessage.columns.isRead <- isRead,
            CustomMessage.columns.isDeleted <- isDeleted))
    }
    
    func verify(db: Connection) throws {
        let query = CustomMessage.table.select(CustomMessage.columns.id, CustomMessage.columns.isDeleted, CustomMessage.columns.isRead).filter(CustomMessage.columns.link == link.absoluteString)
        if let row = try db.pluck(query) {
            rowid = row[CustomMessage.columns.id]
            isRead = row[CustomMessage.columns.isRead]
            isDeleted = row[CustomMessage.columns.isDeleted]
        } else {
            try insert(db: db)
        }
    }
    
    func insert(db: Connection) throws {
        rowid = try db.run(CustomMessage.table.insert(or: .ignore,
                                              CustomMessage.columns.title <- title,
                                              CustomMessage.columns.link <- link.absoluteString,
                                              CustomMessage.columns.description <- description,
                                              CustomMessage.columns.category <- category,
                                              CustomMessage.columns.pubDate <- pubDate,
                                              CustomMessage.columns.isRead <- isRead,
                                              CustomMessage.columns.isDeleted <- isDeleted))
    }
}

extension CustomMessage: Equatable {
    static func == (lhs: CustomMessage, rhs: CustomMessage) -> Bool {
        return lhs.title == rhs.title &&
            lhs.link == rhs.link &&
            lhs.description == rhs.description &&
            lhs.category == rhs.category &&
            lhs.pubDate == rhs.pubDate
    }
}

extension CustomMessage: Hashable {
    var hashValue: Int {
        return link.hashValue ^ title.hashValue ^ description.hashValue ^ category.hashValue ^ pubDate.hashValue
    }
}

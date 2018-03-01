/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2018, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

// The example code uses an RSS feed and merges that into the CombinedInboxViewController. If you don't, you won't need this class.

import Foundation

class FeedParser: NSObject {
    let sourceURL = URL(string: "https://www-03.ibm.com/press/us/en/rssfeed.wss?keyword=null&maxFeed=&feedType=RSS&topic=all")
    var values: [String: Any?]?
    let validNodes = ["title", "pubDate", "category", "link", "description"]
    var currentElement: String?
    var partialTextNode: String?
    let delegate: CustomInboxDatabase
    
    init(delegate: CustomInboxDatabase) {
        self.delegate = delegate
        super.init()
        DispatchQueue.global(qos: .background).async {
            self.retrieveFeed(url: self.sourceURL)
        }
    }
    
    func retrieveFeed(url: URL?) {
        guard let url = url, let parser = XMLParser(contentsOf: url) else { return }
        parser.delegate = self
        parser.parse()
    }
    
    func parseElementText() {
        guard let element = currentElement,
            validNodes.contains(element),
            let text = partialTextNode?.trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
        
        switch element {
        case "pubDate":
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            values?[element] = formatter.date(from: text)
            break
        case "link":
            values?[element] = URL(string: text)
            break
        default:
            values?[element] = text
            break
        }
    }
}

extension FeedParser: XMLParserDelegate {
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate.parserComplete()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            values = [String: Any?]()
        } else {
            currentElement = elementName
            partialTextNode = ""
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Couldn't parse feed \(parseError)")
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print("Couldn't validate feed \(validationError)")
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let currentElement = currentElement,
            validNodes.contains(currentElement)
            else { return }
        
        partialTextNode? += string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let currentElement = currentElement,
            validNodes.contains(currentElement),
            let string = String(data: CDATABlock, encoding: .utf8)
            else { return }
        
        partialTextNode? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item",
            let title = values?["title"] as? String,
            let link = values?["link"] as? URL,
            let description = values?["description"] as? String,
            let category = values?["category"] as? String,
            let pubDate = values?["pubDate"] as? Date {
            let customMessage = CustomMessage(title: title, link: link, description: description, category: category, pubDate: pubDate)
            delegate.parsedCustomMessage(customMessage: customMessage)
        } else {
            parseElementText()
        }
    }
}


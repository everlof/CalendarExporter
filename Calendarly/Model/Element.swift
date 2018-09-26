import Foundation

class Element {

    let tag: Tag

    var children: [Element]

    var content: Content?

    var attr: [String: String]

    var style: [String: AnyObject]

    enum Content {
        case css([CSSRule])
        case text(String)
    }

    enum Tag: String {
        case html
        case head
        case body
        case a
        case table
        case tr
        case th
        case td
        case h1
        case span
        case div
        case style
        case meta
    }

    init(tag: Tag,
         content: Content? = nil,
         attr: [String: String] = [:],
         style: [String: AnyObject] = [:],
         children: [Element] = []) {
        self.tag = tag
        self.content = content
        self.attr = attr
        self.style = style
        self.children = children
    }

    // MARK: Shortcuts inits

    static var html: Element { return Element(tag: .html) }
    static var head: Element { return Element(tag: .head) }
    static var body: Element { return Element(tag: .body) }
    static var a: Element { return Element(tag: .a) }
    static var table: Element { return Element(tag: .table) }
    static var tr: Element { return Element(tag: .tr) }
    static var th: Element { return Element(tag: .th) }
    static var td: Element { return Element(tag: .td) }
    static var h1: Element { return Element(tag: .h1) }
    static var span: Element { return Element(tag: .span) }
    static var div: Element { return Element(tag: .div) }
    static func style(_ cssRules: [CSSRule]) -> Element {
        return Element(tag: .style, content: .css(cssRules), children: [])
    }

    // MARK: Export

    func export(prettyPrint: Bool = false) -> String {
        return exportRecursive(prettyPrint: prettyPrint, depth: 0)
    }

    private func exportRecursive(prettyPrint: Bool = false, depth: Int) -> String {
        let value: String
        if let payload = self.payload(depth: depth) {
            value = payload
        } else if !children.isEmpty {
            value = children.map({ $0.exportRecursive(prettyPrint: prettyPrint, depth: depth + 1) }).joined(separator: "\n")
        } else {
            value = ""
        }

        var attrString = attr.isEmpty ? "" : " "
        for (k, v) in attr {
            attrString += String(format: "%@=\"%@\" ", k, v)
        }

        if prettyPrint {
            if value.isEmpty {
                return String(format: "%@<%@%@/>",
                              String(repeating: " ", count: depth * 4),
                              self.tag.rawValue,
                              attrString)
            } else {
                var returnValue: String = String(format: "%@<%@%@>",
                                                 String(repeating: " ", count: depth * 4),
                                                 self.tag.rawValue,
                                                 attrString)
                if !value.isEmpty {
                    returnValue.append(String(format: "\n%@", value))
                }
                return returnValue.appending(String(format: "\n%@</%@>", String(repeating: " ", count: depth * 4), self.tag.rawValue))
            }
        } else {
            return String(format: "<%@%@>%@</%@>",
                          self.tag.rawValue,
                          attrString,
                          children.map({ $0.exportRecursive(prettyPrint: prettyPrint, depth: depth + 1) }).joined(separator: ""),
                          self.tag.rawValue)
        }
    }

    private func payload(depth: Int) -> String? {
        guard let content = content else { return nil }
        switch content {
        case let .css(rules):
            return rules.map({ String(repeating: " ", count: depth * 4) + $0.export() }).joined(separator: "\n")
        case let .text(text):
            return String(repeating: " ", count: (depth + 1) * 4) + text
        }
    }

    // MARK: Modify

    @discardableResult func append(_ children: Element...) -> Element {
        self.children.append(contentsOf: children)
        return self
    }

}

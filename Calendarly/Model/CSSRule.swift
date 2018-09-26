import Foundation

class CSSRule {

    let selectors: [String]

    let rules: [String: String]

    init(selectors: [String], rules: [String: String]) {
        self.selectors = selectors
        self.rules = rules
    }

    func export() -> String {
        let selectors = self.selectors.joined(separator: ", ")
        let rules = self.rules.map({ $0 + ": " + $1 + ";" }).joined(separator: "")
        return selectors + "{" + rules + "}"
    }

}

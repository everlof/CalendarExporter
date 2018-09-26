import Foundation

extension Locale {

    static func localizedDescription(for identifier: String) -> String {
        return (Locale.autoupdatingCurrent as NSLocale).displayName(forKey: .identifier, value: identifier)!
    }

}

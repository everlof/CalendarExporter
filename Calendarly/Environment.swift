import Foundation

struct Environment {

    static let current = Environment()

    var drawDebugColors: Bool {
        return ProcessInfo.processInfo.environment["DebugColors"] == "1"
    }

}

import UIKit

extension CGSize {

    static var A3: CGSize {
        return CGSize(width: 3504, height: 4950)
    }

    static var A4: CGSize {
        return CGSize(width: 2480, height: 3504)
    }

    static var A5: CGSize {
        return CGSize(width: 2480*(1/sqrt(2)), height: 2480)
    }

    static var A6: CGSize {
        return CGSize(width: 2480*(1/sqrt(2))*(1/sqrt(2)), height: 2480*(1/sqrt(2)))
    }

}

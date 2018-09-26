import UIKit

extension UIColor {

    static var secondaryTextColor: UIColor {
        return UIColor(red: 0x99/0xFF, green: 0x99/0xFF, blue: 0x99/0xFF, alpha: 0xFF)
    }

    static var boneWhiteColor: UIColor {
        return UIColor(red: 0xE3/0xFF, green: 0xDA/0xFF, blue: 0xC9/0xFF, alpha: 0xFF)
    }

    static var boneConstrastDarker: UIColor {
        return UIColor(red: 0xC0/0xFF, green: 0xB3/0xFF, blue: 0x9A/0xFF, alpha: 0xFF)
    }

    static var boneConstrastDarkest: UIColor {
        return UIColor(red: 0xA1/0xFF, green: 0x90/0xFF, blue: 0x6F/0xFF, alpha: 0xFF)
    }

    static var greenMatchingBone: UIColor {
        return UIColor(red: 0x44/0xFF, green: 0x63/0xFF, blue: 0x61/0xFF, alpha: 0xFF)
    }

    static var purpleMatchingBone: UIColor {
        return UIColor(red: 0x57/0xFF, green: 0x50/0xFF, blue: 0x6F/0xFF, alpha: 0xFF)
    }

    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format: "#%06x", rgb)
    }

}

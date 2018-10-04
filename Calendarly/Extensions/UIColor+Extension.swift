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

    convenience init(hexString: String) {
        let hexString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner            = Scanner(string: hexString as String)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        var color:UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:1)
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

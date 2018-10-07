import UIKit

class FontsizeCell: UITableViewCell {

    let design: Design

    let keyPath: ReferenceWritableKeyPath<Design, Float>

    let maximumFractionDigits: Int

    lazy var numberFormatter: NumberFormatter = {
        let nbrFormatter = NumberFormatter()
        nbrFormatter.maximumFractionDigits = self.maximumFractionDigits
        return nbrFormatter
    }()

    init(design: Design,
         keyPath: ReferenceWritableKeyPath<Design, Float>,
         stepValue: Double,
         maximumFractionDigits: Int,
         minimiumValue: Double = 0,
         maximumValue: Double = 0) {
        self.design = design
        self.keyPath = keyPath
        self.maximumFractionDigits = maximumFractionDigits

        super.init(style: .default, reuseIdentifier: nil)
        textLabel?.text = "\(number) units"
        detailTextLabel?.text = "Fontsize"
        selectionStyle = .none

        let stepper = UIStepper(frame: .zero)
        stepper.sizeToFit()
        stepper.value = Double(self.design[keyPath: self.keyPath])
        //        stepper.minimumValue = 0.1
        //        stepper.maximumValue = 3.0
        stepper.stepValue = stepValue
        stepper.isContinuous = false
        stepper.addTarget(self, action: #selector(change), for: .valueChanged)

        accessoryView = stepper
    }

    var number: String {
        return numberFormatter.string(from: NSNumber(value: self.design[keyPath: self.keyPath])) ?? ""
    }

    @objc func change() {
        self.design[keyPath: self.keyPath] = Float((accessoryView as! UIStepper).value)
        textLabel?.text = "\(number) units"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

import UIKit
import BLTNBoard

class YearPickerBLTNItem: FeedbackPageBLTNItem {

    class ContainerView: UIView {
        lazy var stepper = UIStepper(frame: .zero)

        override var intrinsicContentSize: CGSize {
            return CGSize(width: UIView.noIntrinsicMetric, height: stepper.intrinsicContentSize.height)
        }
    }

    let containerView = ContainerView(frame: .zero)

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        containerView.stepper.minimumValue = 2000
        containerView.stepper.maximumValue = 2050
        containerView.stepper.addTarget(self, action: #selector(step), for: .valueChanged)
        containerView.stepper.value = 2019

        containerView.addSubview(containerView.stepper)
        containerView.stepper.translatesAutoresizingMaskIntoConstraints = false
        containerView.stepper.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        actionButtonTitle = "I choose year \(Int(containerView.stepper.value))"

        return [containerView]
    }

    @objc func step() {
        actionButtonTitle = "I choose year \(Int(containerView.stepper.value))"
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
    }

}

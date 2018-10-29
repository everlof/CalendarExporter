import UIKit
import BLTNBoard

class DatePickerBLTItem: BLTNPageItem /* FeedbackPageBLTNItem */ {

    class ContainerView: UIView {
        lazy var datePicker: UIDatePicker = {
            let picker = UIDatePicker(frame: .zero)
            picker.datePickerMode = .date
            return picker
        }()

        override var intrinsicContentSize: CGSize {
            return CGSize(width: UIView.noIntrinsicMetric, height: datePicker.intrinsicContentSize.height)
        }
    }

    let containerView = ContainerView(frame: .zero)

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        containerView.addSubview(containerView.datePicker)
        containerView.datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.datePicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        return [containerView]
    }

}

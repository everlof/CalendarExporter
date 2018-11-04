import UIKit
import BLTNBoard

class CakeViewBLTNItem: BLTNPageItem /* FeedbackPageBLTNItem */ {

    let cakeView = CakeView()

    let containerView = UIView()

    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        containerView.addSubview(cakeView)

        containerView.centerXAnchor.constraint(equalTo: cakeView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: cakeView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: cakeView.bottomAnchor).isActive = true

        cakeView.translatesAutoresizingMaskIntoConstraints = false
        cakeView.widthAnchor.constraint(equalToConstant: 128).isActive = true
        cakeView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        return [containerView]
    }

}

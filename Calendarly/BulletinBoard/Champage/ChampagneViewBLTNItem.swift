import UIKit
import BLTNBoard

class ChampagneViewBLTNItem: BLTNPageItem /* FeedbackPageBLTNItem */ {

    let champagneView = ChampagneView()

    let containerView = UIView()

    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        containerView.addSubview(champagneView)

        containerView.centerXAnchor.constraint(equalTo: champagneView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: champagneView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: champagneView.bottomAnchor).isActive = true

        champagneView.translatesAutoresizingMaskIntoConstraints = false
        champagneView.widthAnchor.constraint(equalToConstant: 128).isActive = true
        champagneView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        return [containerView]
    }

}

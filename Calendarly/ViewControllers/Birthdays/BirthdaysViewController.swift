// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit
import CoreData
import Contacts

class BirthdaysNavigationController: UINavigationController {

    let birthdayViewController: BirthdaysViewController

    init(persistentContainer: NSPersistentContainer) {
        birthdayViewController = BirthdaysViewController(persistentContainer: persistentContainer)
        super.init(nibName: nil, bundle: nil)
        setViewControllers([birthdayViewController], animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BirthdaysViewController: UIViewController {

    let segmentedControl: UISegmentedControl

    let persistentContainer: NSPersistentContainer

    let pageViewController: BirthdaysPageViewController

    let containerView = UIView()

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        segmentedControl = UISegmentedControl(items: [
            "Active",
            "Contacts",
            "Facebook"
        ])
        self.pageViewController = BirthdaysPageViewController(persistentContainer: persistentContainer, segmentedControl: segmentedControl)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func contextChanged(notification: NSNotification) {
        updateTitles()
    }

    func updateTitles() {
        let nbrActive = NSFetchRequest<Birthday>(entityName: Birthday.self.description())
        do {
            let count = try persistentContainer.viewContext.count(for: nbrActive)
            segmentedControl.setTitle("Active (\(count))", forSegmentAt: 0)
        } catch { }

        let nbrContacts = NSFetchRequest<Contact>(entityName: Contact.self.description())
        do {
            let count = try persistentContainer.viewContext.count(for: nbrContacts)
            segmentedControl.setTitle("Contacts (\(count))", forSegmentAt: 1)
        } catch { }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentedControl)
        view.addSubview(containerView)

        segmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        segmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true

        containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        navigationItem.title = "Birthdays"
        updateTitles()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextChanged),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: persistentContainer.viewContext)

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(got(notification:)),
//                                               name: .moveImageNotification,
//                                               object: nil)


        land(with: FlyingView.active, findLandingpoint: { () -> CGPoint in
            let segmentWidth = self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)
            return CGPoint(x: self.segmentedControl.frame.origin.x + (segmentWidth / 2),
                           y: self.segmentedControl.frame.origin.y + self.segmentedControl.frame.height / 2)
        })

        land(with: FlyingView.contact, findLandingpoint: { () -> CGPoint in
            let segmentWidth = self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)
            return CGPoint(x: self.segmentedControl.frame.origin.x + segmentWidth + (segmentWidth / 2),
                           y: self.segmentedControl.frame.origin.y + self.segmentedControl.frame.height / 2)
        })
    }

    @objc func segmentedValueChanged() {
        guard let activeViewControllers = pageViewController.viewControllers as? [PageViewControllerChild] else { return }
        guard let first = activeViewControllers.first else { return }
        guard first.index != segmentedControl.selectedSegmentIndex else { return }

        if first.index < segmentedControl.selectedSegmentIndex {
            pageViewController.setViewControllers([pageViewController.viewControllerList[segmentedControl.selectedSegmentIndex]], direction: .forward, animated: true, completion: nil)
        } else {
            pageViewController.setViewControllers([pageViewController.viewControllerList[segmentedControl.selectedSegmentIndex]], direction: .reverse, animated: true, completion: nil)
        }
    }


//    @objc func got(notification: NSNotification) {
//        guard let contactCell = notification.object as? ContactCell else { return }
//        let imageToAnimate = notification.userInfo?["image"] as! UIImage
//        let rectInGlobalCoordinates = notification.userInfo?["globalRect"] as! CGRect
//        let rectInViewCoordinates = view.convert(rectInGlobalCoordinates, from: nil)
//
//        // Create `UIImageView` to animate.
//        let imageViewToAnimate = UIImageView(frame: rectInViewCoordinates)
//        imageViewToAnimate.image = imageToAnimate
//        view.addSubview(imageViewToAnimate)
//
//        // Animate its scale.
//        let resizeAnimation = CABasicAnimation(keyPath: "bounds.size")
//        resizeAnimation.toValue = CGSize.zero
//        resizeAnimation.fillMode = .forwards
//        resizeAnimation.isRemovedOnCompletion = false
//
//        // Animate it along a path.
//        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
//        pathAnimation.calculationMode = .cubic
//        pathAnimation.fillMode = .forwards
//        pathAnimation.isRemovedOnCompletion = false
//
//        let startPoint = CGPoint(x: imageViewToAnimate.frame.origin.x + imageViewToAnimate.frame.width / 2,
//                                 y: imageViewToAnimate.frame.origin.y + imageViewToAnimate.frame.height / 2)
//
//        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
//
//        let endPoint = CGPoint(x: segmentedControl.frame.origin.x + (segmentWidth / 2),
//                               y: segmentedControl.frame.origin.y + segmentedControl.frame.height / 2)
//
//
//        var midPoint = CGPoint(x: (endPoint.x + startPoint.x) / 2,
//                               y: (endPoint.y + startPoint.y) / 2)
//
//        let startToEndDistance = hypotf(Float(startPoint.x) - Float(endPoint.x), Float(startPoint.y) - Float(endPoint.y))
//
//        // Move the mid point a bit to the right
//        midPoint.x += CGFloat(startToEndDistance / 2)
//
//        // Construct the path
//        let path = CGMutablePath()
//        path.move(to: startPoint)
//        path.addCurve(to: endPoint, control1: midPoint, control2: endPoint)
//        pathAnimation.path = path
//
//        // Construct group frmo animations
//        let group = CAAnimationGroup()
//        group.fillMode = .forwards
//        group.isRemovedOnCompletion = false
//        group.animations = [resizeAnimation, pathAnimation]
//        group.duration = 0.5
//        group.set {
//            imageViewToAnimate.removeFromSuperview()
//            contactCell.animatedCompletly()
//        }
//
//        imageViewToAnimate.layer.add(group, forKey: "addBirthdayAnimation")
//    }


}

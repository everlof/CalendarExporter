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

class BirthdaysPageViewController: UIPageViewController,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate {

    let persistentContainer: NSPersistentContainer

    let segmentedControl: UISegmentedControl

    lazy var viewControllerList: [PageViewControllerChild] = {
        return [
            BirthdayListViewController(index: 0, persistentContainer: self.persistentContainer),
            ContactListViewController(index: 1, persistentContainer: self.persistentContainer),
            BirthdayListViewController(index: 2, persistentContainer: self.persistentContainer)
        ]
    }()

    init(persistentContainer: NSPersistentContainer, segmentedControl: UISegmentedControl) {
        self.persistentContainer = persistentContainer
        self.segmentedControl = segmentedControl
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        dataSource = self
        delegate = self
        setViewControllers([viewControllerList[0]], direction: .forward, animated: false, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let child = viewController as! PageViewControllerChild

        if child.index > 0 {
            return viewControllerList[child.index - 1]
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let child = viewController as! PageViewControllerChild

        if child.index < viewControllerList.count - 1 {
            return viewControllerList[child.index + 1]
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let child = viewControllers?.first as? PageViewControllerChild {
            segmentedControl.selectedSegmentIndex = child.index
        }
    }

}

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

class CallbackContainer {

    var callback: (() -> Void)

    init(callback: @escaping (() -> Void)) {
        self.callback = callback
    }

}

struct FlyingView {
    static let active = NSObject()
    static let contact = NSObject()
}


extension Notification.Name {
    static let flyingView = Notification.Name(rawValue: "flyingView")
}

enum CurveDirection {
    case right
}

func land(with object: Any, findLandingpoint: @escaping (() -> CGPoint), curveDirection: CurveDirection = .right, withView view: UIView) {
    NotificationCenter.default.addObserver(forName: .flyingView, object: object, queue: nil) { notification in
        let imageToAnimate = notification.userInfo?["image"] as! UIImage
        let rectInGlobalCoordinates = notification.userInfo?["globalRect"] as! CGRect
        let callbackContainer = notification.userInfo?["callback"] as? CallbackContainer
        let rectInViewCoordinates = view.convert(rectInGlobalCoordinates, from: nil)

        // Create `UIImageView` to animate.
        let imageViewToAnimate = UIImageView(frame: rectInViewCoordinates)
        imageViewToAnimate.image = imageToAnimate
        view.addSubview(imageViewToAnimate)

        // Animate its scale.
        let resizeAnimation = CABasicAnimation(keyPath: "bounds.size")
        resizeAnimation.toValue = CGSize.zero
        resizeAnimation.fillMode = .forwards
        resizeAnimation.isRemovedOnCompletion = false

        // Animate it along a path.
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = .cubic
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false

        let endPoint = findLandingpoint()
        let startPoint = CGPoint(x: imageViewToAnimate.frame.origin.x + imageViewToAnimate.frame.width / 2,
                                 y: imageViewToAnimate.frame.origin.y + imageViewToAnimate.frame.height / 2)

        var midPoint = CGPoint(x: (endPoint.x + startPoint.x) / 2,
                               y: (endPoint.y + startPoint.y) / 2)

        let startToEndDistance = hypotf(Float(startPoint.x) - Float(endPoint.x), Float(startPoint.y) - Float(endPoint.y))

        // Move the mid point a bit to the right
        midPoint.x += CGFloat(startToEndDistance / 2)

        // Construct the path
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: midPoint, control2: endPoint)
        pathAnimation.path = path

        // Construct group frmo animations
        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.animations = [resizeAnimation, pathAnimation]
        group.duration = 0.5
        group.set {
            imageViewToAnimate.removeFromSuperview()
            callbackContainer?.callback()
        }

        imageViewToAnimate.layer.add(group, forKey: "flyAnimation")
    }
}

extension UIViewController {

    func land(with object: Any, findLandingpoint: @escaping (() -> CGPoint), curveDirection: CurveDirection = .right) {
        Calendarly.land(with: object, findLandingpoint: findLandingpoint, curveDirection: curveDirection, withView: view)
    }

}

extension UIView {

    func takeOff(with object: Any, completed: (() -> Void)? = nil) {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            NotificationCenter.default.post(name: .flyingView,
                                            object: object,
                                            userInfo: [
                "image": image,
                "globalRect": convert(bounds, to: nil),
                "callback": (completed == nil ? nil : CallbackContainer(callback: completed!)) as Any
            ])
        }
        UIGraphicsEndImageContext()
    }

    func land(with object: Any, findLandingpoint: @escaping (() -> CGPoint), curveDirection: CurveDirection = .right) {
        Calendarly.land(with: object, findLandingpoint: findLandingpoint, curveDirection: curveDirection, withView: self)
    }

}

extension CAAnimation: CAAnimationDelegate {

    private struct AssociatedKeys {
        static var callbackKey = "CAAnimationGroup_callbackKey"
    }

    func set(completion: @escaping (() -> Void)) {
        objc_setAssociatedObject(self,
                                 &AssociatedKeys.callbackKey,
                                 CallbackContainer(callback: completion),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let callbackContainer = objc_getAssociatedObject(self, &AssociatedKeys.callbackKey) as? CallbackContainer, flag {
            callbackContainer.callback()
            delegate = nil
        }
        objc_setAssociatedObject(self, &AssociatedKeys.callbackKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

}

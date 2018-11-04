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


import Foundation
import UIKit

class ChampagneView: UIView {


    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        let url = Bundle.main.url(forResource: "ChampagneView", withExtension: "caar")!

        // Read the .caar file into memory
        //
        let data = try! Data(contentsOf: url)

        // Unarchive the NSKeyedArchive as a Dictionary
        //
        guard let rootObject = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)) as? [String: Any] else { return }

        // Pull out the 'rootLayer' object containing the archived CALayer
        //
        guard let rootLayer = rootObject["rootLayer"] as? CALayer else { return }

        // Un-flip the layer for iOS's coordinate system
        //
        rootLayer.isGeometryFlipped = false

        // Start the rootLayer's timeline at the current time
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rootLayer.beginTime = CACurrentMediaTime()
        }

        // Add it to the layer hierarchy
        //
        layer.addSublayer(rootLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        
    }

 }

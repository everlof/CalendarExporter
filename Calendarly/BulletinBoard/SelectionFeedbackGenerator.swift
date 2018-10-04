//
//  SelectionFeedbackGenerator.swift
//  Calendarly
//
//  Created by David Everlöf on 2018-10-04.
//  Copyright © 2018 David Everlöf. All rights reserved.
//

import Foundation
import UIKit

class SelectionFeedbackGenerator {

    let feedbackGenerator = UISelectionFeedbackGenerator()

    func prepare() {
        feedbackGenerator.prepare()
    }

    func selectionChanged() {
        feedbackGenerator.selectionChanged()
    }

}

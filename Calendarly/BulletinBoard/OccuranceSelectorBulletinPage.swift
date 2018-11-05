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
import BLTNBoard

/**
 * An item that displays a choice with two buttons.
 *
 * This item demonstrates how to create a page bulletin item with a custom interface, and changing the
 * next item based on user interaction.
 */

class OccuranceSelectorBulletinPage: FeedbackPageBLTNItem {

    var isOnce: Bool? = nil

    private var onceButtonContainer: UIButton!
    private var recurringButtonContainer: UIButton!
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()

    // MARK: - BLTNItem

    /**
     * Called by the manager when the item is about to be removed from the bulletin.
     *
     * Use this function as an opportunity to do any clean up or remove tap gesture recognizers /
     * button targets from your views to avoid retain cycles.
     */

    override func tearDown() {
        onceButtonContainer?.removeTarget(self, action: nil, for: .touchUpInside)
        recurringButtonContainer?.removeTarget(self, action: nil, for: .touchUpInside)
    }

    /**
     * Called by the manager to build the view hierachy of the bulletin.
     *
     * We need to return the view in the order we want them displayed. You should use a
     * `BulletinInterfaceFactory` to generate standard views, such as title labels and buttons.
     */

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        // We add choice cells to a group stack because they need less spacing
        let stack = interfaceBuilder.makeGroupStack(spacing: 16)

        // Cat Button
        let onceContainer = createChoiceCell(buttonText: "Once", isSelected: false)
        onceContainer.addTarget(self, action: #selector(onceButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(onceContainer)

        self.onceButtonContainer = onceContainer

        // Dog Button

        let recurringContainer = createChoiceCell(buttonText: "Recurring", isSelected: false)
        recurringContainer.addTarget(self, action: #selector(recurringButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(recurringContainer)

        self.recurringButtonContainer = recurringContainer

        return [stack]

    }

    // MARK: - Custom Views

    /**
     * Creates a custom choice cell.
     */

    func createChoiceCell(buttonText: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2

        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        let buttonColor = isSelected ? appearance.actionButtonColor : .lightGray
        button.layer.borderColor = buttonColor.cgColor
        button.setTitleColor(buttonColor, for: .normal)
        button.layer.borderColor = buttonColor.cgColor

        return button

    }

    // MARK: - Touch Events

    /// Called when the cat button is tapped.
    @objc func onceButtonTapped() {
        // Play haptic feedback
        isOnce = true

        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()

        // Update UI
        let onceButtonColor = appearance.actionButtonColor
        onceButtonContainer?.layer.borderColor = onceButtonColor.cgColor
        onceButtonContainer?.setTitleColor(onceButtonColor, for: .normal)

        let recurringButtonColor = UIColor.lightGray
        recurringButtonContainer?.layer.borderColor = recurringButtonColor.cgColor
        recurringButtonContainer?.setTitleColor(recurringButtonColor, for: .normal)
    }

    /// Called when the dog button is tapped.
    @objc func recurringButtonTapped() {
        // Play haptic feedback
        isOnce = false

        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()

        // Update UI

        let onceButtonColor = UIColor.lightGray
        onceButtonContainer?.layer.borderColor = onceButtonColor.cgColor
        onceButtonContainer?.setTitleColor(onceButtonColor, for: .normal)

        let recurringButtonColor = appearance.actionButtonColor
        recurringButtonContainer?.layer.borderColor = recurringButtonColor.cgColor
        recurringButtonContainer?.setTitleColor(recurringButtonColor, for: .normal)
    }

    override func actionButtonTapped(sender: UIButton) {

        // Play haptic feedback
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()

        // Ask the manager to present the next item.
        manager?.displayNextItem()
    }

}

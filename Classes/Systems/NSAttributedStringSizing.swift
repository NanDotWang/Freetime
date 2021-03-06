//
//  NSAttributedStringSizing.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/14/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit

final class NSAttributedStringSizing: NSObject, IGListDiffable {
    let inset: UIEdgeInsets
    let attributedText: NSAttributedString
    let textViewSize: CGSize

    // NSTextContainer
    let exclusionPaths: [UIBezierPath]
    let maximumNumberOfLines: Int
    let lineFragmentPadding: CGFloat

    // NSLayoutManager
    let allowsNonContiguousLayout: Bool
    let hyphenationFactor: CGFloat
    let showsInvisibleCharacters: Bool
    let showsControlCharacters: Bool
    let usesFontLeading: Bool

    init(
        containerWidth: CGFloat,
        attributedText: NSAttributedString,
        inset: UIEdgeInsets = .zero,
        exclusionPaths: [UIBezierPath] = [],
        maximumNumberOfLines: Int = 0,
        lineFragmentPadding: CGFloat = 0.0,
        allowsNonContiguousLayout: Bool = false,
        hyphenationFactor: CGFloat = 0.0,
        showsInvisibleCharacters: Bool = false,
        showsControlCharacters: Bool = false,
        usesFontLeading: Bool = true,
        screenScale: CGFloat = UIScreen.main.scale
        ) {
        self.attributedText = attributedText
        self.inset = inset
        self.exclusionPaths = exclusionPaths
        self.maximumNumberOfLines = maximumNumberOfLines
        self.lineFragmentPadding = lineFragmentPadding
        self.allowsNonContiguousLayout = allowsNonContiguousLayout
        self.hyphenationFactor = hyphenationFactor
        self.showsInvisibleCharacters = showsInvisibleCharacters
        self.showsControlCharacters = showsControlCharacters
        self.usesFontLeading = usesFontLeading

        let insetWidth = containerWidth - inset.left - inset.right
        let textContainer = NSTextContainer(size: CGSize(width: insetWidth, height: 0))
        textContainer.exclusionPaths = exclusionPaths
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.lineFragmentPadding = lineFragmentPadding

        let layoutManager = NSLayoutManager()
        layoutManager.allowsNonContiguousLayout = allowsNonContiguousLayout
        layoutManager.hyphenationFactor = hyphenationFactor
        layoutManager.showsInvisibleCharacters = showsInvisibleCharacters
        layoutManager.showsControlCharacters = showsControlCharacters
        layoutManager.usesFontLeading = usesFontLeading
        layoutManager.addTextContainer(textContainer)

        // storage implicitly required to use NSLayoutManager + NSTextContainer and find a size
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)

        // find the size of the text now that everything is configured
        let bounds = layoutManager.usedRect(for: textContainer)

        // adjust for the text view inset (contentInset + textContainerInset)
        var viewSize = bounds.size
        viewSize.width += inset.left + inset.right
        viewSize.height += inset.top + inset.bottom

        // snap to pixel
        viewSize.width = ceil(viewSize.width * screenScale) / screenScale
        viewSize.height = ceil(viewSize.height * screenScale) / screenScale
        self.textViewSize = viewSize
    }

    func configure(textView: UITextView) {
        textView.attributedText = attributedText
        textView.contentInset = .zero
        textView.textContainerInset = inset

        let textContainer = textView.textContainer
        textContainer.exclusionPaths = exclusionPaths
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.lineFragmentPadding = lineFragmentPadding

        let layoutManager = textView.layoutManager
        layoutManager.allowsNonContiguousLayout = allowsNonContiguousLayout
        layoutManager.hyphenationFactor = hyphenationFactor
        layoutManager.showsInvisibleCharacters = showsInvisibleCharacters
        layoutManager.showsControlCharacters = showsControlCharacters
        layoutManager.usesFontLeading = usesFontLeading
        layoutManager.addTextContainer(textContainer)
    }

    // MARK: IGListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return attributedText
    }

    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? NSAttributedStringSizing else { return false }
        return textViewSize == object.textViewSize
    }

}

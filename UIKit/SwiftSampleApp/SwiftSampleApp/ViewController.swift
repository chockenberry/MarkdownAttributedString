//
//  ViewController.swift
//  SwiftSampleApp
//
//  Created by Craig Hockenberry on 2/2/20.
//  Copyright © 2020 The Iconfactory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var simpleLabel: UILabel!
	@IBOutlet var advancedLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// simple example
		do {
			let markdownString = "This is a **_simple_ example** that _shows_ **Markdown** being used for attributed strings."
			
			let attributedString = NSAttributedString(markdownRepresentation: markdownString, attributes: [.font : UIFont.systemFont(ofSize: 17.0), .foregroundColor: UIColor.systemPurple ])
			
			simpleLabel.attributedText = attributedString;
		}
		
		// advanced example
		do {
			let shadow = NSShadow()
			shadow.shadowColor = UIColor.systemOrange.withAlphaComponent(0.75)
			shadow.shadowOffset = CGSize(width: 1, height: 1)
			shadow.shadowBlurRadius = 2

			let baseAttributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .title2), .foregroundColor: UIColor.systemTeal, .shadow: shadow]
			
			let styleAttributes: [MarkdownStyleKey: [NSAttributedString.Key : Any]] = [
				.emphasisSingle: [ .font: UIFont.preferredFont(forTextStyle: .title2), .foregroundColor: UIColor.systemTeal, .underlineColor: UIColor.systemIndigo, .underlineStyle: 1 ],
				.emphasisDouble: [ .font: UIFont.preferredFont(forTextStyle: .title1), .foregroundColor: UIColor.systemBlue ],
				.emphasisBoth: [ .font: UIFont.preferredFont(forTextStyle: .title1), .strokeColor: UIColor.systemBlue, .strokeWidth: 3 ]
			]
			
			let markdownString = NSLocalizedString("**Advanced _features_** let you adjust _individual_ styles, but it's still _simple_ to do with **Markdown**.", comment: "Use Markdown in localized strings!")

			let attributedString = NSAttributedString(markdownRepresentation: markdownString, baseAttributes: baseAttributes, styleAttributes: styleAttributes)
			
			advancedLabel.attributedText = attributedString;
		}
	}


}


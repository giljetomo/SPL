//
//  UILabel+boldRegularText.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-18.
//

import UIKit

extension UILabel {
  public func setRegualAndBoldText(regualText: String, boldText: String) {
      let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: font.pointSize)]
      let regularString = NSMutableAttributedString(string: regualText)
      let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
      boldString.append(regularString)
      attributedText = boldString
  }
}

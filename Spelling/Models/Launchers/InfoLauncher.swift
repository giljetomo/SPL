//
//  InfoLauncher.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-28.
//

import UIKit
import BuyMeACoffee

class InfoLauncher: NSObject {
  
  var windowHeight: CGFloat?
  let blackView = UIView()
  let view: UIView = {
    let v = UIView()
    v.clipsToBounds = true
    v.layer.cornerRadius = 12
    v.backgroundColor = Color.screenColor
    v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    return v
  }()
  let bmcButton: BMCButton = {
    let b = BMCButton(configuration: .default)
    b.translatesAutoresizingMaskIntoConstraints = false
    b.configuration = .init(color: .yellow, font: .cookie)
    return b
  }()
  
  lazy var textView: UITextView = {
    let tv = UITextView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    let text = """
              SPL works best with US-Tom (Enhanced) and UK-Daniel (Enhanced) voices installed from:\n
              Settings ＞ Accessibility ＞ Spoken Content ＞ Voices ＞ English\n
              Privacy Policy
              """
    let attributedString = NSMutableAttributedString(string: text)
    
    let allTextRange = attributedString.mutableString.range(of: text)
    let settingsRange = attributedString.mutableString.range(of: "Settings")
    let splRange = attributedString.mutableString.range(of: "SPL")
    let tomRange = attributedString.mutableString.range(of: "US-Tom")
    let danielRange = attributedString.mutableString.range(of: "UK-Daniel")
    let chevronRange = attributedString.mutableString.range(of: "＞")
    
    attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: allTextRange)
    attributedString.addAttribute(.foregroundColor, value: Color.textColor, range: allTextRange)
    attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 22)], range: splRange)
    attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: tomRange)
    attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], range: danielRange)
    
    let chevronRanges = text.ranges(of: "＞")
    chevronRanges.forEach {
      attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 19), range: NSRange($0, in: text))
    }
    
    if let link = URL(string: UIApplication.openSettingsURLString) {
      attributedString.addAttribute(.link, value: link, range: settingsRange)
    }
    tv.linkTextAttributes = [
      .foregroundColor: UIColor.systemBlue,
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 19), range: settingsRange)
    
    tv.isEditable = false
    tv.attributedText = attributedString
    tv.backgroundColor = .clear
    tv.textAlignment = .center
    return tv
  }()
  
  func showInfo() {
    if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
      blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
      blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
      
      window.addSubview(blackView)
      blackView.frame = window.frame
      blackView.alpha = 0
      
      window.addSubview(view)
      
      windowHeight = window.frame.height
      guard let windowHeight = windowHeight else { return }
      let height = windowHeight * 0.40
      view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
        self.blackView.alpha = 1
        self.view.frame = CGRect(x: 0, y: windowHeight - height, width: self.view.frame.width, height: self.view.frame.height)
      }
    }
  }
  override init() {
    super.init()
    
    view.addSubview(textView)
    textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
    textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70).isActive = true
    textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive = true
    
    view.addSubview(bmcButton)
    bmcButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    bmcButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 3).isActive = true
  }
  
  @objc func dismissView() {
    UIView.animate(withDuration: 0.5) {
      self.blackView.alpha = 0
      if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        self.view.frame = CGRect(x: 0, y: window.frame.height, width: self.view.frame.width, height: self.view.frame.height)
      }
    }
  }
  
}

extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}

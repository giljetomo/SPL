//
//  UIColor+HEX.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-26.
//

import UIKit

enum HexColor: String {
  case darkScreen = "#212121"
  case lightScreen = "#eff1f4"
  case darkText = "#171316"
  case lightText = "#f1f1f1"
  case darkButtonBackground = "#c9cecb"
  case darkButtonText = "#2e2b29"
  case lightTableviewScreen = "#fffcf5"
}

struct Color {
  static var textColor: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor(hexString: HexColor.lightText.rawValue)
      default: return UIColor(hexString: HexColor.darkText.rawValue)
      }
    }
  }
  static var screenColor: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor(hexString: HexColor.darkScreen.rawValue)
      default: return UIColor(hexString: HexColor.lightScreen.rawValue)
      }
    }
  }
  static var buttonColorBackground: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor(hexString: HexColor.lightText.rawValue)
      default: return UIColor(hexString: HexColor.darkButtonBackground.rawValue)
      }
    }
  }
  static var buttonColorText: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor(hexString: HexColor.darkScreen.rawValue)
      default: return UIColor(hexString: HexColor.darkButtonText.rawValue)
      }
    }
  }
  static var tableviewColor: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor(hexString: HexColor.darkScreen.rawValue)
      default: return UIColor(hexString: HexColor.lightTableviewScreen.rawValue)
      }
    }
  }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//
//  Keyboard.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-25.
//

import Foundation

struct Keyboard {
  
  static func getItems(at section: KeyboardSection) -> [String] {
    switch section {
    case .one: return ["q","w","e","r","t","y","u","i","o","p"]
    case .two: return ["a","s","d","f","g","h","j","k","l"]
    case .three: return ["z","x","c","v","b","n","m","CLR","DEL"]
    }
  }
}

enum KeyboardSection: Int, CaseIterable {
  case one
  case two
  case three
}

enum KeyboardOption {
  case keyboard
  case shuffled
  case cryptic
}

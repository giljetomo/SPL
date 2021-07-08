//
//  Language.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-14.
//

import Foundation

enum Country: String {
  case US = "en_US"
  case UK = "en_GB"
  
  mutating func toggle() {
    self = self == .US ? .UK : .US
  }
}

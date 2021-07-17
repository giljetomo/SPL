//
//  Favorite.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-09.
//

import Foundation

enum Favorite: String {
  case liked = "heart_filled"
  case unliked = "heart"
  
  mutating func toggle() {
    self = self == .liked ? .unliked : .liked
  }
}

//
//  Keyboard.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-25.
//

import Foundation

struct Keyboard {
  
  static func getKeyboardItems(at section: KeyboardSection) -> [String] {
    switch section {
    case .one: return ["q","w","e","r","t","y","u","i","o","p"]
    case .two: return ["a","s","d","f","g","h","j","k","l"]
    case .three: return ["z","x","c","v","b","n","m","CLR","DEL"]
    }
  }
  
  static func getShuffledWord(for word: String) -> [[String]] {
    let arr = word.map { String($0) }
    let wordSet = Array(Set(arr))
    let itemsPerRow = Int(ceil(Double(wordSet.count) / 3.0))
    var collection = [[String]](repeating: [String](), count: 3)
    var counter = 0
    
    for section in 0...2 {
      for _ in 0..<itemsPerRow {
        guard counter < wordSet.count else { break }
        collection[section].append(wordSet[counter])
        counter += 1
      }
    }
    collection[2].append(contentsOf: ["CLR", "DEL"])
    return collection
  }
  
  static func getConcealedWord(word: String) -> [[String]] {
    let text = word.map { String($0) }
    var dict = text.reduce(into: [String: Int]()) { $0[$1] = 1 }
    
    let sets = [["s", "z", "c"],
                ["d", "t"],
                ["f", "v", "b", "p"],
                ["g", "j", "h"],
                ["i", "y", "e", "a"],
                ["a", "o", "u", "w"],
                ["k", "c", "q"]]
    
    for set in sets {
      for char in text {
        if set.contains(char) {
          let filtered = set.filter { $0 != char }
          for item in filtered where dict[item] == nil { dict[item] = 1 }
          break
        }
      }
    }
    return getShuffledWord(for: dict.keys.compactMap { String($0) }.joined())
  }
}

enum KeyboardSection: Int, CaseIterable {
  case one
  case two
  case three
}

enum KeyboardOption: Int {
  case keyboard
  case shuffled
  case concealed
}

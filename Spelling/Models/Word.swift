//
//  Word.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-14.
//

import Foundation

struct Word {
  var text: String
  var definition: [String: String]
  var audio: URL?
  
  var searchURL: URL? {
    let searchText = "define \(text)"
    let text = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let query = "https://www.google.com/search?q=\(text)"
    return URL(string: query)
  }
  
  static func maskWord(_ str: String, from text: String) -> String {
    let count = Int(ceil(Double(str.count) * 0.60))
    let newText = str.prefix(count)
    let asterisks = String(repeating: "*", count: count)

    return text.replacingOccurrences(of: newText, with: asterisks, options: .caseInsensitive)
  }
}

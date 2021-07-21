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
  
}

//
//  Word.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-14.
//

import Foundation

struct WordAPI: Codable {
  var word: String
  var phonetics: [Phonetics]
  var meanings: [Meanings]
}

struct Phonetics: Codable {
  var audio: URL
}

struct Meanings: Codable {
  var partOfSpeech: String
  var definitions: [Definition]
}

struct Definition: Codable {
  var definition: String
}

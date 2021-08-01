//
//  AppSettings.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-29.
//

import Foundation

struct AppSettings {
  @Storage(key: .word, defaultValue: "")
  static var word: String
  
  @Storage(key: .language, defaultValue: Country.US.rawValue)
  static var language: String
  
  @Storage(key: .level, defaultValue: Level.tourist.rawValue)
  static var level: String
  
  @Storage(key: .volume, defaultValue: 0.90)
  static var volume: Float
  
  @Storage(key: .keyboard, defaultValue: KeyboardOption.keyboard.rawValue)
  static var keyboard: Int
  
  @Storage(key: .isFirstLoad, defaultValue: false)
  static var isFirstLoad: Bool
  
  @Storage(key: .isFirstInstall, defaultValue: true)
  static var isFirstInstall: Bool
  
  @Storage(key: .launchScreenWord, defaultValue: "pronounce")
  static var launchScreenWord: String
  
  @Storage(key: .touristSpellCount, defaultValue: 0)
  static var touristSpellCount: Int
  
  @Storage(key: .immigrantSpellCount, defaultValue: 0)
  static var immigrantSpellCount: Int
  
  @Storage(key: .citizenSpellCount, defaultValue: 0)
  static var citizenSpellCount: Int
  
  @Storage(key: .presidentSpellCount, defaultValue: 0)
  static var presidentSpellCount: Int
}


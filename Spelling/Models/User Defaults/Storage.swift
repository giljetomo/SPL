//
//  Storage.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-29.
//

import Foundation

@propertyWrapper
struct Storage<T> {
  private let key: StorageKey
  private let defaultValue: T
  
  init(key: StorageKey, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  var wrappedValue: T {
    get { return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue }
    set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
  }
}

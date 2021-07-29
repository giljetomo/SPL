//
//  Level.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-17.
//

import Foundation
import UIKit

enum Level: String, CaseIterable {
  case tourist //61,553
  case citizen //56,199
  case immigrant //58,055
  case president //16,906
  
  var range: CountableClosedRange<Int32> {
    switch self {
    case .tourist: return 4...7
    case .immigrant: return 8...9
    case .citizen: return 10...12
    case .president: return 13...21
    }
  }
}

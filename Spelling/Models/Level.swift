//
//  Level.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-17.
//

import Foundation

enum Level: String {
  case TRAVELLER //61,553
  case IMMIGRANT //58,055
  case CITIZEN //56,199
  case PRESIDENT //16,906
  
  var range: CountableClosedRange<Int32> {
    switch self {
    case .TRAVELLER: return 4...7
    case .IMMIGRANT: return 8...9
    case .CITIZEN: return 10...12
    case .PRESIDENT: return 13...21
    }
  }
}

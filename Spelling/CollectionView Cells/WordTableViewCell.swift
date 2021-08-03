//
//  WordTableViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-19.
//

import UIKit

class WordTableViewCell: UITableViewCell {
  static let reuseIdentifier = "WordTableViewCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

//
//  WordCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-07.
//

import UIKit

class WordCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "WordCollectionViewCell"
  
  let wordLabel: UIPaddedLabel = {
    let lbl = UIPaddedLabel(top: 5, bottom: 5, left: 5, right: 5)
    lbl.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    lbl.adjustsFontForContentSizeCategory = true
    lbl.adjustsFontSizeToFitWidth = true
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.layer.masksToBounds = true
    lbl.layer.cornerRadius = 5
//    lbl.backgroundColor = .white
    return lbl
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(wordLabel)
//  constraints need to be applied so the button does not overflow outside the contentView
    wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
    wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
    wordLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    contentView.layer.cornerRadius = 5
//    contentView.backgroundColor = .cyan
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(with text: String) {
    wordLabel.text = text
  }
}

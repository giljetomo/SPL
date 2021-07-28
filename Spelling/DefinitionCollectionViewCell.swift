//
//  DefinitionCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-17.
//

import UIKit



class DefinitionCollectionViewCell: UICollectionViewCell {
  static var isFirstLoadDone: Bool?
  static let reuseIdentifier = "DefinitionCollectionViewCell"
  var isAnimated = false
  
  let definitionLabel: UIPaddedLabel = {
    let lbl = UIPaddedLabel(top: 5, bottom: 5, left: 5, right: 5)
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.numberOfLines = 0
    lbl.textAlignment = .center
    lbl.layer.masksToBounds = true
    lbl.layer.cornerRadius = 5
    lbl.adjustsFontForContentSizeCategory = true
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textColor = Color.textColor
    return lbl
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(definitionLabel)
//  constraints need to be applied so the button does not overflow outside the contentView
    definitionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    definitionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    definitionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    definitionLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    contentView.layer.cornerRadius = 5
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(with partOfSpeech: String, and definition: String) {
    definitionLabel.font = .preferredFont(forTextStyle: DefinitionCollectionViewCell.isFirstLoadDone != nil ? .callout : .title3)
    definitionLabel.setRegualAndBoldText(regualText: definition, boldText: "\(partOfSpeech) ")
  }
}



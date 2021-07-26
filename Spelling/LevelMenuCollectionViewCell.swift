//
//  LevelMenuCollectionViewCell.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-07-23.
//

import UIKit

class LevelMenuCollectionViewCell: UICollectionViewCell {
 
  let label: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.font = .preferredFont(forTextStyle: .title2)
    lbl.textAlignment = .center
    lbl.textColor = .black
    return lbl
  }()
  
  static let reuseIdentifier = "LevelMenuCollectionViewCell"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    //constraints need to be applied so the button does not overflow outside the contentView
    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1).isActive = true
    label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1).isActive = true
    label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
    label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
    contentView.backgroundColor = .gray
    contentView.layer.cornerRadius = 8
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

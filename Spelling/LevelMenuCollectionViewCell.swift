//
//  LevelMenuCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-23.
//

import UIKit

class LevelMenuCollectionViewCell: UICollectionViewCell {
 
  static let reuseIdentifier = "LevelMenuCollectionViewCell"
  
  let label: UILabel = {
    let lbl = UILabel()
    lbl.font = .preferredFont(forTextStyle: .title3)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    lbl.textColor = Color.textColor
    return lbl
  }()
  
  let subLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = .preferredFont(forTextStyle: .subheadline)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    lbl.textColor = Color.textColor
    return lbl
  }()
  
  lazy var hStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [label, subLabel])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .vertical
    sv.distribution = .fill
    sv.alignment = .center
    return sv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(hStackView)
    
    hStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    hStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    contentView.backgroundColor = Color.screenColor
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = false
    contentView.layer.shadowRadius = 4
    contentView.layer.shadowColor = Color.textColor.cgColor
    contentView.layer.shadowOpacity = 0.5
    contentView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

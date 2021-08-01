//
//  LevelMenuCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-23.
//

import UIKit
import CoreData

class LevelMenuCollectionViewCell: UICollectionViewCell {
 
  static let reuseIdentifier = "LevelMenuCollectionViewCell"
  var container: NSPersistentContainer? = AppDelegate.persistentContainer
  
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
    lbl.font = .preferredFont(forTextStyle: .body)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    lbl.textColor = Color.textColor
    return lbl
  }()
  
  let countLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = .preferredFont(forTextStyle: .footnote)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    lbl.textColor = Color.textColor
    return lbl
  }()
  
  lazy var hStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [label, subLabel, countLabel])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .vertical
    sv.distribution = .fill
    sv.alignment = .center
    sv.spacing = 2
    return sv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(hStackView)
    
    hStackView.centerXYin(contentView)
    
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
  
  func setup(with level: Level) {
    let count: Int = {
      switch level {
      case .tourist: return AppSettings.touristSpellCount
      case .immigrant: return AppSettings.immigrantSpellCount
      case .citizen: return AppSettings.citizenSpellCount
      case .president: return AppSettings.presidentSpellCount
      }
    }()
    
    label.text = level.rawValue.uppercased()
    subLabel.text = "\(level.range.lowerBound) to \(level.range.upperBound) letters"
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    guard let value = numberFormatter.string(from: NSNumber(value: count)) else { return }
    countLabel.text = "\(value) word\(count == 1 ? "" : "s") left"
  }
  
}

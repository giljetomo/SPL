//
//  RestaurantCollectionViewCell.swift
//  My Restaurants
//
//  Created by Gil Jetomo on 2021-02-04.
//

import UIKit

protocol KeyboardCollectionViewCellDelegate: class {
  func keyPressed(for key: String)
}

class KeyboardCollectionViewCell: UICollectionViewCell {
  
  var isAnimated = false
  static let reuseIdentifier = "filterCell"
  weak var delegate: KeyboardCollectionViewCellDelegate?
  
  var letterButton: UIButton = {
    let btn = UIButton()
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    btn.layer.cornerRadius = 5
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.titleLabel?.adjustsFontForContentSizeCategory = true
    btn.backgroundColor = UIColor(named: "White")
    btn.layer.masksToBounds = false
    btn.layer.shadowRadius = 1
    btn.layer.shadowColor = Color.textColor.cgColor
    btn.layer.shadowOpacity = 0.5
    btn.layer.shadowOffset = CGSize(width: 1, height: 1)
    btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    return btn
  }()
  
  @objc func keyboardPressed(_ sender: UIButton) {
    UIView.animate(withDuration: 0.10) {
      sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        sender.transform = .identity
      }
    }
    
    if let key = sender.title(for: .normal) {
      delegate?.keyPressed(for: key)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(letterButton)
    //constraints need to be applied so the button does not overflow outside the contentView
    letterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1).isActive = true
    letterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1).isActive = true
    letterButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
    letterButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

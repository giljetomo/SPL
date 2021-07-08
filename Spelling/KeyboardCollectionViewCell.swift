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

  static let reuseIdentifier = "filterCell"
  weak var delegate: KeyboardCollectionViewCellDelegate?
  
  var letterButton: UIButton = {
    let btn = UIButton()
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    btn.layer.cornerRadius = 6
    btn.layer.borderWidth = 1 / UIScreen.main.scale
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.backgroundColor = .white
    btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
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

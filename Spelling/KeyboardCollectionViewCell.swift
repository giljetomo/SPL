//
//  RestaurantCollectionViewCell.swift
//  My Restaurants
//
//  Created by Gil Jetomo on 2021-02-04.
//

import UIKit

protocol KeyboardCollectionViewCellDelegate: class {
  func filterSelected()
}

class KeyboardCollectionViewCell: UICollectionViewCell {

  static let reuseIdentifier = "filterCell"
  weak var delegate: KeyboardCollectionViewCellDelegate?
  
  var button: HighlightedButton = {
    let btn = HighlightedButton()
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    btn.layer.cornerRadius = 6
    btn.layer.borderWidth = 1 / UIScreen.main.scale
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
    return btn
  }()
  
  @objc func buttonPressed(_ sender: UIButton) {
    UIView.animate(withDuration: 0.10) {
      sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        sender.transform = .identity
      }
    }
    sender.isSelected.toggle()
    
    delegate?.filterSelected()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(button)
    //constraints need to be applied so the button does not overflow outside the contentView
    button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1).isActive = true
    button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1).isActive = true
    button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
    button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

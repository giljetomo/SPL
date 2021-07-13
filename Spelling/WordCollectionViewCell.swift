//
//  WordCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-07.
//

import UIKit

protocol WordCollectionViewCellDelegate: class {
  func isWordLiked(status: Bool)
}

class WordCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "WordCollectionViewCell"
  weak var delegate: WordCollectionViewCellDelegate?
  
  let view: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  
  let wordLabel: UIPaddedLabel = {
    let lbl = UIPaddedLabel(top: 5, bottom: 5, left: 5, right: 5)
    lbl.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    lbl.adjustsFontForContentSizeCategory = true
    lbl.adjustsFontSizeToFitWidth = true
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.layer.masksToBounds = true
    lbl.layer.cornerRadius = 5
    return lbl
  }()
  var liked: Favorite = .unliked {
    didSet {
      heartImageView.image = UIImage(named: liked.rawValue)
    }
  }
  lazy var playTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
  let heartImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.image = UIImage(named: "heart")
    iv.contentMode = .scaleAspectFill
    iv.tintColor = .darkGray
    iv.isUserInteractionEnabled = true
    return iv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    heartImageView.addGestureRecognizer(playTapRecognizer)
    
    view.addSubview(heartImageView)
    heartImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    heartImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    heartImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.50).isActive = true
    heartImageView.widthAnchor.constraint(equalTo: heartImageView.heightAnchor, multiplier: 1).isActive = true
    
    view.addSubview(wordLabel)
    wordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    wordLabel.trailingAnchor.constraint(equalTo: heartImageView.leadingAnchor, constant: -5).isActive = true
    wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: heartImageView.intrinsicContentSize.width).isActive = true
    
    contentView.addSubview(view)
    //  constraints need to be applied so the button does not overflow outside the contentView
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    contentView.layer.cornerRadius = 5
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(with text: String) {
    wordLabel.text = text
  }
  
  @objc func tapped() {
    liked.toggle()
    
    UIView.animate(withDuration: 0.10) {
      self.heartImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        self.heartImageView.transform = .identity
      }
    }
    delegate?.isWordLiked(status: liked == .liked)
  }
}

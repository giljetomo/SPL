//
//  WordCollectionViewCell.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-07.
//

import UIKit

protocol WordCollectionViewCellDelegate: class {
  func isWordLiked(status: Bool)
  func wordTapped()
}

class WordCollectionViewCell: UICollectionViewCell {
  static var allAnimationsLoaded: Bool?
  static let reuseIdentifier = "WordCollectionViewCell"
  weak var delegate: WordCollectionViewCellDelegate?
  
  let view: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  lazy var wordTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(wordTapped))
  let wordLabel: UIPaddedLabel = {
    let lbl = UIPaddedLabel(top: 5, bottom: 5, left: 5, right: 5)
    lbl.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    lbl.adjustsFontForContentSizeCategory = true
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    lbl.isUserInteractionEnabled = true
    return lbl
  }()
  var liked: Favorite = .unliked {
    didSet {
      heartImageView.image = UIImage(named: liked.rawValue)
    }
  }
  var searchInSafari: (() -> ())?
  lazy var heartTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(heartTapped))
  let heartImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.image = UIImage(named: "heart")
    iv.contentMode = .scaleAspectFill
    iv.tintColor = .darkGray
    iv.isUserInteractionEnabled = true
    return iv
  }()
  
  lazy var hStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [UIView(), wordLabel, UIView()])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.distribution = .equalCentering
    sv.alignment = .center
    sv.spacing = 0
    return sv
  }()
  
  @objc func animationsEnded() { WordCollectionViewCell.allAnimationsLoaded = true }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    heartImageView.addGestureRecognizer(heartTapRecognizer)
    wordLabel.addGestureRecognizer(wordTapRecognizer)
    
    contentView.addSubview(view)
    //  constraints need to be applied so the button does not overflow outside the contentView
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    contentView.layer.cornerRadius = 5
    
    view.addSubview(heartImageView)
    heartImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    heartImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    heartImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.50).isActive = true
    heartImageView.widthAnchor.constraint(equalTo: heartImageView.heightAnchor, multiplier: 1).isActive = true
    
    view.addSubview(hStackView)
    hStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    hStackView.trailingAnchor.constraint(equalTo: heartImageView.leadingAnchor, constant: -5).isActive = true
    hStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: heartImageView.intrinsicContentSize.width + 15.0).isActive = true
    hStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(with text: String) {
    wordLabel.text = text
  }
  
  @objc func heartTapped() {
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
  
  @objc func wordTapped() {
    guard WordCollectionViewCell.allAnimationsLoaded != nil else {
      delegate?.wordTapped()
      return }
    
    UIView.animate(withDuration: 0.10) { [weak self] in
      self?.wordLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) { [weak self] in
        self?.wordLabel.transform = .identity
      } completion: { [weak self] (_) in
        self?.searchInSafari?()
      }
    }
  }
  
}

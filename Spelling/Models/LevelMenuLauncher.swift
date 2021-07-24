//
//  LevelMenuLauncher.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-07-23.
//

import UIKit

protocol LevelMenuLauncherDelegate: class {
  func changeLevel(to level: Level)
}

class LevelMenuLauncher: NSObject {
  
  var windowHeight: CGFloat?
  let levels = ["Traveller", "Immigrant", "Citizen", "President"]
  weak var delegate: LevelMenuLauncherDelegate?
  var selectedLevel: Level?
    
  lazy var menuCollectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    cv.backgroundColor = .white
    cv.clipsToBounds = true
    cv.layer.cornerRadius = 12
    cv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    return cv
  }()
  
  let blackView = UIView()
  
  func showMenu() {
    if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
      blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
      blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
      
      window.addSubview(blackView)
      blackView.frame = window.frame
      blackView.alpha = 0
      
      window.addSubview(menuCollectionView)
      windowHeight = window.frame.height
      guard let windowHeight = windowHeight else { return }
      let height = (windowHeight * 0.30)
      menuCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
        self.blackView.alpha = 1
        self.menuCollectionView.frame = CGRect(x: 0, y: windowHeight - height, width: self.menuCollectionView.frame.width, height: self.menuCollectionView.frame.height)
      } completion: { (_) in
        
      }
      
    }
  }
  
  override init() {
    super.init()
    
    menuCollectionView.delegate = self
    menuCollectionView.dataSource = self
    menuCollectionView.register(LevelMenuCollectionViewCell.self, forCellWithReuseIdentifier: LevelMenuCollectionViewCell.reuseIdentifier)
    menuCollectionView.collectionViewLayout = generateLayout()
  }
  
  @objc func dismissView() {
    UIView.animate(withDuration: 0.5) {
      self.blackView.alpha = 0
      if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
        self.menuCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.menuCollectionView.frame.width, height: self.menuCollectionView.frame.height)
      }
    } completion: { [weak self] (_) in
      guard let level = self?.selectedLevel else { return }
      self?.delegate?.changeLevel(to: level)
    }
  }
  
  private func generateLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let padding = layoutEnvironment.container.contentSize.width * 0.05
      
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)))
      item.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/2),
          heightDimension: .fractionalHeight(1.0)),
        subitem: item,
        count: 2)
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      return section
      
    }
    return layout
  }
}

extension LevelMenuLauncher: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return levels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LevelMenuCollectionViewCell.reuseIdentifier, for: indexPath) as! LevelMenuCollectionViewCell
    let item = levels[indexPath.item]
    cell.label.text = item
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? LevelMenuCollectionViewCell else { return }
    
    UIView.animate(withDuration: 0.10) {
      cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        cell.transform = .identity
      } completion: { (_) in
        self.selectedLevel = Level(rawValue: self.levels[indexPath.item].lowercased())
        self.dismissView()
      }
    }
  }
  
}

//
//  LaunchScreenViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-07-30.
//

import UIKit
import CoreData

class LaunchScreenViewController: UIViewController {
  
  var container: NSPersistentContainer? = AppDelegate.persistentContainer
  var strings = ["spell", "learn"]
  let label = UILabel()
  
  lazy var vStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: getLabels())
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .vertical
    sv.alignment = .fill
    sv.distribution = .fill
    sv.spacing = view.frame.height * 0.01
    return sv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(hexString: HexColor.launchScreen.rawValue)
    
    strings.insert(AppSettings.launchScreenWord, at: 1)
    
    view.addSubview(vStackView)
    vStackView.centerXYin(view)
    vStackView.anchors(topAnchor: nil,
                       leadingAnchor: view.leadingAnchor,
                       trailingAnchor: view.trailingAnchor,
                       bottomAnchor: nil,
                       padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                       size: .zero)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let context = container?.viewContext,
       let label = vStackView.arrangedSubviews[1] as? UILabel,
       let word = try? ManagedWord.getPWord(in: context)?.text {
      
      UIView.transition(with: label, duration: 0.8, options: .transitionFlipFromTop) {
        label.text = word
        UIView.animate(withDuration: 0.10) {
          label.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        } completion: { (_) in
          UIView.animate(withDuration: 0.20) {
            label.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
          } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
              label.transform = .identity
            } completion: { (_) in
              AppSettings.launchScreenWord = word
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
                splashTimeOut()
              }
            }
          }
        }
      }
      
    }
    
  }
  
  private func getLabels() -> [UILabel] {
    var labels = [UILabel]()
    
    strings.forEach { (string) in
      let lbl = UILabel()
      lbl.font = .preferredFont(forTextStyle: .title1)
      lbl.text = string
      lbl.textColor = Color.textColor
      lbl.adjustsFontForContentSizeCategory = true
      lbl.adjustsFontSizeToFitWidth = true
      lbl.textAlignment = .center
      labels.append(lbl)
    }
    return labels
  }
  
  private func splashTimeOut() {
    guard let window = SceneDelegate.shared?.window else { return }
  
    window.rootViewController = MainViewController()
    UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)
  }
  
}

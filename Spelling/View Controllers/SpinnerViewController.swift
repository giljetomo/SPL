//
//  SpinnerViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-07-29.
//

import UIKit

class SpinnerViewController: UIViewController {
  var spinner = UIActivityIndicatorView(style: .large)
  
  override func loadView() {
    view = UIView()
    view.layer.cornerRadius = 8
    
    view.backgroundColor = UIColor(hexString: HexColor.darkButtonBackground.rawValue)
    view.alpha = 0.4
    spinner.color = .black
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}

//
//  ViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-14.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
  
  var word: Word?
  var country: Country = .US
  var successfulFetch = true
  
  let words = ["hello","asdfadsf","fabulous","mother","sdfsd","hero","sdss","example","handkerchief", "sir", "right", "hello", "obstreperous", "caa", "finish", "pair", "occur"]
  var index = 0
  
  let topView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.layer.cornerRadius = 4
    v.backgroundColor = .lightGray
    return v
  }()
  
  var dictionViewIsOpen = true
  var dictionViewWidthConstraint: NSLayoutConstraint!
  lazy var dictionTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeLanguage))
  let dictionView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.layer.cornerRadius = 4
    v.backgroundColor = .white
    return v
  }()
  lazy var dictionVStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [languageLabel, dictionUS, dictionUK])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.alignment = .center
    sv.distribution = .fillEqually
    sv.spacing = 5
    return sv
  }()
  let languageLabel: UILabel = {
    let lbl = UILabel()
    lbl.text = "US"
    lbl.font = .systemFont(ofSize: 16)
    return lbl
  }()
  
  let playButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Play", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
    return btn
  }()
  
  
  let dictionUS: UIButton = {
    let btn = UIButton()
    btn.setTitle("US", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(changeDiction(_:)), for: .touchUpInside)
    btn.isHidden = true
    return btn
  }()
  
  let dictionUK: UIButton = {
    let btn = UIButton()
    btn.setTitle("UK", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.isHidden = true
    btn.addTarget(self, action: #selector(changeDiction(_:)), for: .touchUpInside)
    return btn
  }()
  
  let nextB: UIButton = {
    let btn = UIButton()
    btn.setTitle("Next", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(getNext(_:)), for: .touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "White")
    setupViewLayout()
    
    NotificationCenter.default.addObserver(self, selector: #selector(changeButtonStatePlayMode), name: .playbackEnded, object: nil)
    
    fetchWordAPI(with: country) {(successful)  in
      self.changeButtonStateAfterFetch(successful)
    }
  }
  
  fileprivate func setupViewLayout() {
    view.addSubview(topView)
    view.addSubview(playButton)
    view.addSubview(nextB)
    
    
    topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
    topView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
    topView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
    topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    topView.addSubview(dictionView)
    dictionViewWidthConstraint = NSLayoutConstraint(
      item: dictionView,
      attribute: .width,
      relatedBy: .equal,
      toItem: topView,
      attribute: .width,
      multiplier: 0.10,
      constant: 0)
    topView.addConstraint(dictionViewWidthConstraint)
    dictionView.addGestureRecognizer(dictionTapRecognizer)
    dictionView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.80).isActive = true
    dictionView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 8).isActive = true
    dictionView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    
    dictionView.addSubview(dictionVStackView)
    dictionVStackView.leadingAnchor.constraint(equalTo: dictionView.leadingAnchor, constant: 5).isActive = true
    dictionVStackView.centerYAnchor.constraint(equalTo: dictionView.centerYAnchor).isActive = true
    dictionVStackView.centerXAnchor.constraint(equalTo: dictionView.centerXAnchor).isActive = true
    
    playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    playButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    nextB.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 15).isActive = true
    nextB.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
  }
  
  func initPlayer() {
    if let word = word {
      AudioPlayer.shared.initPlayer(with: word.audio)
    }
  }
  
  @objc func pressed(_ sender: UIButton) {
    self.changeButtonStatePlayMode()
    AudioPlayer.shared.play()
  }
  
  func changeButtonStateAfterFetch(_ successful: Bool) {
    playButton.isEnabled = successful
    buttonSetTitleColor()
  }
  
  @objc func changeButtonStatePlayMode() {
    playButton.isEnabled.toggle()
    buttonSetTitleColor()
  }
  
  fileprivate func buttonSetTitleColor() {
    playButton.setTitleColor(playButton.isEnabled ? .systemBlue : .gray, for: .normal)
  }
  
  @objc func getNext(_ sender: UIButton) {
    index += 1
    fetchWordAPI(with: country) { (successful)  in
      self.changeButtonStateAfterFetch(successful)
    }
  }
  
  @objc func changeLanguage() {
    dictionViewIsOpen.toggle()
    
    let language = country == .US ? "US" : "UK"
    let multiplier = CGFloat(dictionViewIsOpen ? 0.10 : 0.30)
    topView.removeConstraint(dictionViewWidthConstraint)
    
    UIView.animate(withDuration: 0.50) {
      self.dictionUK.isHidden.toggle()
      self.dictionUS.isHidden.toggle()
      self.languageLabel.text = self.dictionViewIsOpen ? language : "✗"
      self.dictionViewWidthConstraint = NSLayoutConstraint(
        item: self.dictionView,
        attribute: .width,
        relatedBy: .equal,
        toItem: self.topView,
        attribute: .width,
        multiplier: multiplier,
        constant: 0)
      self.topView.addConstraint(self.dictionViewWidthConstraint)
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func changeDiction(_ sender: UIButton) {
    let title = sender.title(for: .normal) == "US" ? Country.US.rawValue : Country.UK.rawValue
    guard let selectedCountry = Country(rawValue: title), selectedCountry != country else {
      changeLanguage()
      return
    }
    country.toggle()
    changeLanguage()
    fetchWordAPI(with: country) { (successful)  in
      self.changeButtonStateAfterFetch(successful)
    }
  }
  
  fileprivate func fetchWordAPI(with country: Country, completion: @escaping (Bool) -> Void) {
    WordInfoAPI.shared.fetchWordInfoAPI(word: words[index], country: country) { (result) in
      DispatchQueue.main.async { [weak self] in
        switch result {
        case .failure(let error):
          completion(false)
          print(error.localizedDescription)
        case .success(let word):
          if let word = word.first {
            var definition = [String: String]()
            for meaning in word.meanings {
              if let definitionAPI = meaning.definitions.first?.definition {
                definition.updateValue(definitionAPI, forKey: meaning.partOfSpeech)
              }
            }
            if let audio = word.phonetics.first?.audio {
              self?.word = Word(word: word.word, definition: definition, audio: audio)
              self?.initPlayer()
              completion(true)
            } else {
              completion(false)
            }
          }
        }
      }
    }
  }
  
}


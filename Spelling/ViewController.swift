//
//  ViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-14.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
  
  var player = AVPlayer()
  var word: Word?
  var country: Country = .US
  var successfulFetch = true
  
  let words = ["hello","asdfadsf","fabulous","mother","sdfsd","hero","sdss","example","handkerchief", "sir", "right", "hello", "obstreperous", "caa", "finish", "pair", "occur"]
  var index = 0
  
  let button: UIButton = {
    let btn = UIButton()
    btn.setTitle("Play", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
    return btn
  }()
  
  let diction: UIButton = {
    let btn = UIButton()
    btn.setTitle("US", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
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
    view.backgroundColor = .white
    view.addSubview(button)
    view.addSubview(diction)
    view.addSubview(nextB)
    
    button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    diction.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8).isActive = true
    diction.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    nextB.topAnchor.constraint(equalTo: diction.bottomAnchor, constant: 15).isActive = true
    nextB.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    NotificationCenter.default.addObserver(self, selector: #selector(changeButtonStatePlayMode), name: .playbackEnded, object: nil)
    
    fetchWordAPI(with: country) {(successful)  in
      self.changeButtonStateAfterFetch(successful)
    }
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
    button.isEnabled = successful
    diction.isEnabled = successful
    buttonSetTitleColor()
  }
  
  @objc func changeButtonStatePlayMode() {
    button.isEnabled.toggle()
    diction.isEnabled.toggle()
    buttonSetTitleColor()
  }

  fileprivate func buttonSetTitleColor() {
    button.setTitleColor(button.isEnabled ? .systemBlue : .gray, for: .normal)
    diction.setTitleColor(diction.isEnabled ? .systemBlue : .gray, for: .normal)
  }
  
  @objc func getNext(_ sender: UIButton) {
    index += 1
    fetchWordAPI(with: country) { (successful)  in
      self.changeButtonStateAfterFetch(successful)
    }
  }
  
  @objc func changeDiction(_ sender: UIButton) {
    country.toggle()
    sender.setTitle(country == .UK ? "UK" : "US", for: .normal)
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


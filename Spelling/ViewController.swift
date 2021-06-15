//
//  ViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-14.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    WordInfoAPI.shared.fetchWordInfoAPI(word: "voluptuous", country: .US) { (result) in
      switch result {
      case .failure(let error):
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
            let new = Word(word: word.word, definition: definition, audio: audio)
            print(new)
          }
        }
      }
    }
    
  }

}


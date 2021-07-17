//
//  SpeechService.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-13.
//

import Foundation
import AVFoundation

class SpeechService: NSObject {
  static let shared = SpeechService()
  private var speechService = AVSpeechSynthesizer()
  private var utterance: AVSpeechUtterance?
  
  enum Voices: String {
    case US = "com.apple.ttsbundle.siri_female_en-US_premium"
    case UK = "com.apple.ttsbundle.Daniel-premium"
  }
  
  override private init() {
    super.init()
    speechService.delegate = self
  }
  
  func say(_ word: String, in language: String, volume: Float) {
    utterance = AVSpeechUtterance(string: word)
    guard let utterance = self.utterance,
          let country = Country(rawValue: language.replacingOccurrences(of: "-", with: "_"))
    else { return }
    
//    AVSpeechSynthesisVoice.speechVoices().forEach { print ($0) }
    let voices = AVSpeechSynthesisVoice.speechVoices()
                .map { $0.identifier }
                .filter {
                  $0 == Voices.US.rawValue || $0 == Voices.UK.rawValue
                }
    utterance.voice = {
      guard voices.count > 0 else { return AVSpeechSynthesisVoice(language: language) }
      switch country {
      case .UK:
        return voices.contains(Voices.UK.rawValue) ? AVSpeechSynthesisVoice(identifier: Voices.UK.rawValue) : nil
      case .US:
        return voices.contains(Voices.US.rawValue) ? AVSpeechSynthesisVoice(identifier: Voices.US.rawValue) : nil
      }
    }()

    utterance.volume = volume
    utterance.rate = 0.4
    speechService.speak(utterance)
    print(utterance.voice)
  }
  
  func setVolume(to level: Float) {
    guard let utterance = self.utterance else { return }
    utterance.volume = level
  }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    self.utterance = nil
    NotificationCenter.default.post(name: .playbackEnded, object: nil)
  }
}

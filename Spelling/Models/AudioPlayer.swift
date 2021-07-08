//
//  AudioPlayer.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-15.
//

import Foundation
import AVFoundation

class AudioPlayer {
  static let shared = AudioPlayer()
  private var player = AVPlayer()
  
  private init() { }
  
  func initPlayer(with url: URL) {
    //need to remove previous observer when switching diction
    NotificationCenter.default.removeObserver(self)
    
    do {
      let playerItem = AVPlayerItem(url: url)
      player.replaceCurrentItem(with: playerItem)
      
      try AVAudioSession.sharedInstance().setCategory(.playback,
                                                      mode: .default,
                                                      options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true,
                                                    options: .notifyOthersOnDeactivation)
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(playerEndedPlaying),
                                             name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                             object: nil)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func pause(){
    player.pause()
  }
  
  func play() {
    player.play()
    //play speed: 1.0 is the normal rate; below 1.0 means slower
    //player.playImmediately(atRate: 0.7)
  }
  
  func setVolume(to level: Float) {
    player.volume = level
  }
  
  @objc func playerEndedPlaying(_ notification: Notification) {
    player.seek(to: CMTime.zero)
    NotificationCenter.default.post(name: .playbackEnded, object: nil)
  }
  
}

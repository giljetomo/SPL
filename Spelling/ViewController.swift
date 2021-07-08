//
//  ViewController.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-14.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {
  
  var keyboardOption: KeyboardOption = .keyboard
  var shuffledWord = [[String]](repeating: [String](), count: 3)
  var concealedWord = [[String]](repeating: [String](), count: 3)
  var word: Word? {
    didSet {
      guard let word = self.word else {
        shuffledWord = [[String]](repeating: [String](), count: 3)
        concealedWord = [[String]](repeating: [String](), count: 3)
        return
      }
      for (partOfSpeech, _) in word.definition {
        self.partOfSpeech.append(partOfSpeech)
      }
      shuffledWord = Keyboard.getShuffledWord(for: word.word)
      concealedWord = Keyboard.getConcealedWord(word: word.word)
    }
  }
  var country: Country = .US
  var successfulFetch = true
  var partOfSpeech = [String]()
  
  let words = ["wind","uncopyrightable","counterintuitive","acanthopterygian","panegyric","chez","pseudoscientific","diagrammatically","misunderstanding","hakenkreuzler","haecceity","behavior","abhorring","abracadabra","obstreperosity","abfarads","aasvogel","aargh","aaronical","equivalents","equivocated","opprobrium","ggg","clandestine","right","right","sir","pair","quixotic","right","above","apocryphal","sesquipedalian","hello","asdfadsf","fabulous","mother","sdfsd","hero","sdss","example","handkerchief", "sir", "right", "hello", "obstreperous", "caa", "finish", "pair", "occur"]
  var index = 0
  
  let topView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  let definitionView: UIView = {
    let v = UIView()
    v.backgroundColor = .lightGray
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  let keyboardSectionView: UIView = {
    let v = UIView()
    v.backgroundColor = .lightGray
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  let foregroundView: UIView = {
    let v = UIView()
    v.backgroundColor = .black
    v.alpha = 0
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  var definitionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var keyboardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
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
  lazy var dictionHStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [languageLabel, dictionUS, dictionUK])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.alignment = .fill
    sv.distribution = .equalSpacing
    sv.spacing = 5
    return sv
  }()
  let languageLabel: UILabel = {
    let lbl = UILabel()
    lbl.text = "US"
    lbl.font = .systemFont(ofSize: 16)
    lbl.textAlignment = .center
    lbl.layer.masksToBounds = true
    lbl.isUserInteractionEnabled = true
    lbl.setContentHuggingPriority(.required, for: .horizontal)
    lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
    return lbl
  }()
  let levelLabel: UILabel = {
    let lbl = UIPaddedLabel(top: 5, bottom: 5, left: 5, right: 5)
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.text = Level.TRAVELLER.rawValue
    lbl.font = .systemFont(ofSize: 16)
    lbl.layer.masksToBounds = true
    lbl.layer.cornerRadius = 5
    lbl.backgroundColor = .white
    lbl.textAlignment = .center
    return lbl
  }()
  lazy var playTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playAudio))
  let audioImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.image = UIImage(named: "audio")
    iv.contentMode = .scaleAspectFit
    iv.tintColor = .systemBlue
    iv.isUserInteractionEnabled = true
    return iv
  }()
  lazy var audioVStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [audioImageView, volumeSlider])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .vertical
    sv.alignment = .center
    sv.distribution = .fill
    sv.spacing = 15
    return sv
  }()
  var isAudioMuted = false
  let volumeSlider: UISlider = {
    let s = UISlider()
    s.minimumValue = 0.0
    s.maximumValue = 1.0
    s.setValue(0.70, animated: false)
    s.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
    s.widthAnchor.constraint(equalToConstant: 350 / UIScreen.main.scale).isActive = true
    s.setThumbImage(UIImage(named: "slider"), for: .normal)
    s.alpha = 0.20
    s.addTarget(self, action: #selector(changeSlider(_:)), for: .touchDown)
    s.addTarget(self, action: #selector(adjustVolume(_:)), for: .touchUpInside)
    s.addTarget(self, action: #selector(adjustVolume(_:)), for: .touchUpOutside)
    return s
  }()
  var keyboardPosition = CGPoint(x: 0, y: 0)
  lazy var keyboardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragKeyboard))
  lazy var keyboardTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardTapped))
  let keyboardView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.heightAnchor.constraint(equalToConstant: 105.0 / UIScreen.main.scale).isActive = true
    v.clipsToBounds = true
    v.layer.cornerRadius = 5
    v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    v.backgroundColor = .lightGray
    v.isUserInteractionEnabled = true
    return v
  }()
  let keyboardImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.image = UIImage(named: "keyboard")
    iv.tintColor = .black
    iv.isUserInteractionEnabled = true
    iv.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return iv
  }()
  lazy var keyboardHStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [keyboardImageView, keyboardSegmentedControl])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.alignment = .center
    sv.distribution = .fill
    sv.spacing = 3
    return sv
  }()
  var keyboardViewIsOpen = true
  var keyboardViewWidthConstraint: NSLayoutConstraint!
  var keyboardImageViewTrailingConstraint: NSLayoutConstraint!
  var keyboardSegmentedControlWidth: CGFloat!
  var keyboardImageViewWidth: CGFloat!
  let keyboardSegmentedControl: UISegmentedControl = {
    let items = ["Keyboard","Shuffled","Concealed"]
    let sc = UISegmentedControl(items: items)
    let font = UIFont.systemFont(ofSize: 16)
    sc.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
    sc.selectedSegmentIndex = 0
    sc.layer.cornerRadius = 12
    sc.isHidden = true
    sc.addTarget(self, action: #selector(keyboardChanged(_:)), for: .valueChanged)
    return sc
  }()
  let dictionUS: UIButton = {
    let btn = UIButton()
    btn.setTitle("US", for: .normal)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(changeDiction(_:)), for: .touchUpInside)
    btn.isHidden = true
    return btn
  }()
  
  let dictionUK: UIButton = {
    let btn = UIButton()
    btn.setTitle("UK", for: .normal)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.isHidden = true
    btn.addTarget(self, action: #selector(changeDiction(_:)), for: .touchUpInside)
    return btn
  }()
  let guessLabelView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  let guessLabel: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.text = ""
    lbl.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    lbl.adjustsFontForContentSizeCategory = true
    lbl.textAlignment = .center
    return lbl
  }()
  let nextB: UIButton = {
    let btn = UIButton()
    btn.setTitle("Next", for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitleColor(.systemBlue, for: .normal)
    btn.addTarget(self, action: #selector(fetchNextWord(_:)), for: .touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "White")
    
    fetchWordAPI(with: country) {(successful) in
      DispatchQueue.main.async {
        self.definitionCollectionView.delegate = self
        self.definitionCollectionView.dataSource = self
        self.keyboardCollectionView.delegate = self
        self.keyboardCollectionView.dataSource = self
        
        self.definitionCollectionView.collectionViewLayout = self.generateLayout()
        self.keyboardCollectionView.collectionViewLayout = self.generateKeyboardLayout()
        self.changeUIStateAfterFetch(successful)
        UIView.animate(withDuration: 0.50) {
          self.definitionCollectionView.reloadSections([0])
          self.keyboardCollectionView.reloadData()
        }
      }
    }
    
    definitionCollectionView.register(DefinitionCollectionViewCell.self, forCellWithReuseIdentifier: DefinitionCollectionViewCell.reuseIdentifier)
    keyboardCollectionView.register(KeyboardCollectionViewCell.self, forCellWithReuseIdentifier: KeyboardCollectionViewCell.reuseIdentifier)
    definitionCollectionView.backgroundColor = UIColor(named: "White")
    keyboardCollectionView.backgroundColor = UIColor(named: "White")
    setupViewLayout()
    
    NotificationCenter.default.addObserver(self, selector: #selector(changeAudioState), name: .playbackEnded, object: nil)
  }
  override func viewDidLayoutSubviews() {
    if keyboardSegmentedControlWidth == nil { keyboardSegmentedControlWidth = keyboardSegmentedControl.frame.width }
    if keyboardImageViewWidth == nil || keyboardImageViewWidth == 0.0 {
      keyboardImageViewWidth = keyboardImageView.frame.width
    }
  }
  
  private func generateLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(200)))
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: item.layoutSize.heightDimension),
        subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 5
      return section
    }
    return layout
  }
  
  private func generateKeyboardLayout() -> UICollectionViewLayout {
    
    let groupInset = 3 / UIScreen.main.scale
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)))
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/10),
          heightDimension: .fractionalHeight(1/3)),
        subitems: [item])
      group.contentInsets = NSDirectionalEdgeInsets(top: groupInset, leading: groupInset, bottom: groupInset, trailing: groupInset)
      
      var inset: CGFloat = .zero
      var count = 0
      if let keyboardSection = KeyboardSection(rawValue: sectionIndex) {
        if self.keyboardOption == .keyboard {
          count = Keyboard.getKeyboardItems(at: keyboardSection).count
        } else if self.keyboardOption == .shuffled {
          count = self.shuffledWord[sectionIndex].count
        } else if self.keyboardOption == .concealed {
          count = self.concealedWord[sectionIndex].count
        }
        let containerWidth = layoutEnvironment.container.contentSize.width
        let groupWidthDimension = group.layoutSize.widthDimension.dimension
        let itemWidth = containerWidth * groupWidthDimension
        inset = (containerWidth - CGFloat(count) * itemWidth) / 2.0
      }
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = .init(top: 0, leading: round(inset), bottom: 0, trailing: 0)
      section.orthogonalScrollingBehavior = .continuous
      return section
    }
    return layout
  }
  
  fileprivate func setupViewLayout() {
    view.addSubview(topView)
    view.addSubview(definitionView)
    view.addSubview(audioVStackView)
    view.addSubview(guessLabelView)
    view.addSubview(nextB)
    view.addSubview(keyboardSectionView)
    view.addSubview(foregroundView)
    view.addSubview(keyboardView)
    
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
    languageLabel.addGestureRecognizer(dictionTapRecognizer)
    audioImageView.addGestureRecognizer(playTapRecognizer)
    
    dictionView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.80).isActive = true
    dictionView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 8).isActive = true
    dictionView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    
    dictionView.addSubview(dictionHStackView)
    dictionHStackView.widthAnchor.constraint(equalTo: dictionView.widthAnchor, multiplier: 0.90).isActive = true
    dictionHStackView.heightAnchor.constraint(equalTo: dictionView.heightAnchor, multiplier: 0.90).isActive = true
    dictionHStackView.centerYAnchor.constraint(equalTo: dictionView.centerYAnchor).isActive = true
    dictionHStackView.centerXAnchor.constraint(equalTo: dictionView.centerXAnchor).isActive = true
    
    topView.addSubview(levelLabel)
    levelLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
    levelLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    
    topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
    topView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
    topView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
    topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    definitionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10).isActive = true
    definitionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive = true
    definitionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.30).isActive = true
    definitionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    definitionView.addSubview(definitionCollectionView)
    definitionCollectionView.translatesAutoresizingMaskIntoConstraints = false
    definitionCollectionView.widthAnchor.constraint(equalTo: definitionView.widthAnchor, multiplier: 1).isActive = true
    definitionCollectionView.heightAnchor.constraint(equalTo: definitionView.heightAnchor, multiplier: 1).isActive = true
    
    audioImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.07).isActive = true
    audioImageView.widthAnchor.constraint(equalTo: audioImageView.heightAnchor, multiplier: 1).isActive = true
    audioVStackView.topAnchor.constraint(equalTo: definitionCollectionView.bottomAnchor, constant: view.frame.height * 0.02).isActive = true
    audioVStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    guessLabelView.topAnchor.constraint(equalTo: audioVStackView.bottomAnchor, constant: 0).isActive = true
    guessLabelView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.08).isActive = true
    guessLabelView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1).isActive = true
    guessLabelView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    guessLabelView.addSubview(guessLabel)
    guessLabel.centerXAnchor.constraint(equalTo: guessLabelView.centerXAnchor).isActive = true
    guessLabel.centerYAnchor.constraint(equalTo: guessLabelView.centerYAnchor).isActive = true
    
    keyboardSectionView.topAnchor.constraint(equalTo: guessLabelView.bottomAnchor, constant: 10).isActive = true
    keyboardSectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
    keyboardSectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.20).isActive = true
    keyboardSectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    keyboardSectionView.addSubview(keyboardCollectionView)
    keyboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
    keyboardCollectionView.widthAnchor.constraint(equalTo: keyboardSectionView.widthAnchor, multiplier: 1).isActive = true
    keyboardCollectionView.heightAnchor.constraint(equalTo: keyboardSectionView.heightAnchor, multiplier: 1).isActive = true
    
    foregroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
    foregroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
    foregroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    keyboardViewWidthConstraint = NSLayoutConstraint(
      item: keyboardView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: 105.0 / UIScreen.main.scale)
    keyboardView.addConstraint(keyboardViewWidthConstraint)
    
    keyboardView.addGestureRecognizer(keyboardTapRecognizer)
    keyboardView.addGestureRecognizer(keyboardPanRecognizer)
    keyboardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    
    keyboardView.addSubview(keyboardHStackView)
    keyboardHStackView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -5).isActive = true
    keyboardHStackView.centerYAnchor.constraint(equalTo: keyboardView.centerYAnchor).isActive = true
    keyboardHStackView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 0).isActive = true
    
    nextB.topAnchor.constraint(equalTo: keyboardSectionView.bottomAnchor, constant: 20).isActive = true
    nextB.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
  }
  
  func initPlayer() {
    if let word = word {
      AudioPlayer.shared.initPlayer(with: word.audio)
    }
  }
  
  @objc func keyboardChanged(_ sender: UISegmentedControl) {
    keyboardTapped()
    
    guard let option = KeyboardOption(rawValue: sender.selectedSegmentIndex) else { return }
    keyboardOption = option
    UIView.animate(withDuration: 0.5) {
      self.keyboardCollectionView.reloadData()
    }
  }
  
  
  @objc func keyboardTapped() {
    
    keyboardViewIsOpen.toggle()
    
    let constant =
      keyboardViewIsOpen
      ? (keyboardImageViewWidth ?? 0.0)   //105.0 / UIScreen.main.scale
      : ((keyboardImageViewWidth ?? 0.0) + CGFloat(5.0) + (keyboardSegmentedControlWidth ?? 0.0))
    keyboardView.removeConstraint(keyboardViewWidthConstraint)
    
    UIView.animate(withDuration: 0.40) { [weak self] in
      self?.foregroundView.alpha = self!.keyboardViewIsOpen ? 0.0 : 0.7
      self?.keyboardSegmentedControl.isHidden.toggle()
      self?.keyboardViewWidthConstraint = NSLayoutConstraint(
        item: self!.keyboardView,
        attribute: .width,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: constant)
      self?.keyboardView.addConstraint(self!.keyboardViewWidthConstraint)
      self?.view.layoutIfNeeded()
    }
  }
  @objc func dragKeyboard(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.view)
    if gesture.state == .changed {
      keyboardView.transform = CGAffineTransform(translationX: 0, y: translation.y + keyboardPosition.y)
    } else if gesture.state == .ended {
      keyboardPosition.y += translation.y
      guard keyboardPosition.y < -20 || keyboardPosition.y > 250 else { return }
      if keyboardPosition.y < -20 { keyboardPosition.y = -20 }
      else if keyboardPosition.y > 250 { keyboardPosition.y = 250 }
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
        self.keyboardView.transform = CGAffineTransform(translationX: 0, y: self.keyboardPosition.y)
      })
    }
  }
  
  @objc func playAudio() {
    changeAudioState()
    AudioPlayer.shared.play()
  }
  
  @objc func adjustVolume(_ sender: UISlider) {
    sender.alpha = 0.2
    UIView.animate(withDuration: 0.40) { [weak self] in
      sender.transform = .identity
      if sender.value == 0.0 {
        self?.audioImageView.image = UIImage(named: "muted")
        self?.audioImageView.isUserInteractionEnabled = false
        self?.isAudioMuted = true
      } else {
        self?.audioImageView.image = UIImage(named: "audio")
        self?.audioImageView.isUserInteractionEnabled = true
        self?.isAudioMuted = false
      }
    }
    playImageViewSetColor()
    AudioPlayer.shared.setVolume(to: sender.value)
    if sender.value > 0.0 { playAudio() }
  }
  
  @objc func changeSlider(_ sender: UISlider) {
    sender.alpha = 1.0
    UIView.animate(withDuration: 0.30) {
      sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    }
    
  }
  
  func changeUIStateAfterFetch(_ successful: Bool) {
    audioImageView.isUserInteractionEnabled = successful && !isAudioMuted
    volumeSlider.isUserInteractionEnabled = successful
    keyboardView.isUserInteractionEnabled = successful
    playImageViewSetColor()
    if successful { playAudio() }
  }
  
  @objc func changeAudioState() {
    audioImageView.isUserInteractionEnabled.toggle()
    volumeSlider.isUserInteractionEnabled.toggle()
    nextB.isEnabled.toggle()
    
    if audioImageView.isUserInteractionEnabled {
      UIView.animate(withDuration: 0.10) {
        self.playImageViewSetColor()
        self.audioImageView.transform = .identity
      }
    } else {
      UIView.animate(withDuration: 0.50) {
        self.playImageViewSetColor()
        self.audioImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      }
    }
  }
  
  fileprivate func playImageViewSetColor() {
    audioImageView.tintColor = audioImageView.isUserInteractionEnabled ? .systemBlue : .gray
  }
  
  @objc func fetchNextWord(_ sender: UIButton) {
    index += 1
    partOfSpeech.removeAll()
    fetchWordAPI(with: country) { (successful) in
      if !successful { self.word = nil }
      self.changeUIStateAfterFetch(successful)
      self.definitionCollectionView.reloadSections([0])
      self.definitionCollectionView.scrollToItem(at: [0,0], at: .top, animated: false)
      self.keyboardCollectionView.reloadData()
    }
  }
  
  @objc func changeLanguage() {
    dictionViewIsOpen.toggle()
    
    let language = country == .US ? "US" : "UK"
    dictionUK.backgroundColor = country == .US ? .clear : .cyan
    dictionUS.backgroundColor = country == .UK ? .clear : .cyan
    
    let multiplier = CGFloat(dictionViewIsOpen ? 0.10 : 0.30)
    topView.removeConstraint(dictionViewWidthConstraint)
    
    UIView.animate(withDuration: 0.25) { [weak self] in
      self?.dictionUK.isHidden.toggle()
      self?.dictionUS.isHidden.toggle()
      self?.languageLabel.text = ""
      self?.dictionViewWidthConstraint = NSLayoutConstraint(
        item: self!.dictionView,
        attribute: .width,
        relatedBy: .equal,
        toItem: self!.topView,
        attribute: .width,
        multiplier: multiplier,
        constant: 0)
      self?.topView.addConstraint(self!.dictionViewWidthConstraint)
      self?.view.layoutIfNeeded()
    } completion: { (_) in
      UIView.animate(withDuration: 0) { [weak self] in
        self?.languageLabel.text = self!.dictionViewIsOpen ? language : "✖️" //🔙
        self?.view.layoutIfNeeded()
      }
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
    fetchWordAPI(with: country) { [weak self] (successful) in
      self?.changeUIStateAfterFetch(successful)
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
              self?.word = Word(word: word.word.replacingOccurrences(of: "-", with: ""),
                                definition: definition,
                                audio: audio)
              print(self!.word)
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == self.keyboardCollectionView {
      return 3
    }
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIndex: Int) -> Int {
    if collectionView == self.definitionCollectionView {
      if let word = word { return word.definition.count }
      return 1
    } else {
      if let section = KeyboardSection(rawValue: sectionIndex) {
        if keyboardOption == .keyboard {
          switch section {
          case .one: return Keyboard.getKeyboardItems(at: .one).count
          case .two: return Keyboard.getKeyboardItems(at: .two).count
          case .three: return Keyboard.getKeyboardItems(at: .three).count
          }
        } else if keyboardOption == .shuffled {
          switch section {
          case .one: return shuffledWord[0].count
          case .two: return shuffledWord[1].count
          case .three: return shuffledWord[2].count
          }
        } else if keyboardOption == .concealed {
          switch section {
          case .one: return concealedWord[0].count
          case .two: return concealedWord[1].count
          case .three: return concealedWord[2].count
          }
        }
      }
      return 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == self.definitionCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefinitionCollectionViewCell.reuseIdentifier, for: indexPath) as! DefinitionCollectionViewCell
      
      UIView.animate(withDuration: 0.5, delay: 0.5 * Double(indexPath.item), usingSpringWithDamping: 1, initialSpringVelocity: 0.5, animations: {
        AnimationUtility.viewSlideInFromTop(toBottom: cell)
      })
      
      guard let word = word?.definition else {
        cell.setup(with: "Error", and: "Please press next")
        return cell
      }
      let partofSpeech = partOfSpeech[indexPath.item]
      guard let definition = word[partofSpeech] else { return cell }
      cell.setup(with: partofSpeech, and: definition)
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardCollectionViewCell
      guard let section = KeyboardSection(rawValue: indexPath.section) else { return UICollectionViewCell() }
      let items: [String] = {
        switch keyboardOption {
        case .keyboard: return Keyboard.getKeyboardItems(at: section)
        case .shuffled: return shuffledWord[indexPath.section]
        case .concealed: return concealedWord[indexPath.section]
        }
      }()
      cell.letterButton.setTitle(items[indexPath.item], for: .normal)
      cell.letterButton.addTarget(cell, action: #selector(KeyboardCollectionViewCell.keyboardPressed(_:)), for: .touchUpInside)
      cell.delegate = self
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if collectionView == self.definitionCollectionView {
      cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      UIView.animate(withDuration: 0.25) { cell.transform = .identity }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == self.keyboardCollectionView {
      return CGSize(width: (keyboardSectionView.frame.width/9)-5, height: (keyboardSectionView.frame.width/9)-5)
    }
    return .zero
  }
  
}

extension ViewController: KeyboardCollectionViewCellDelegate {
  func keyPressed(for key: String) {
    
    let word: String = {
      if let text = self.guessLabel.text {
        if key.count == 1 { return text + key }
        else if key == "DEL" { return String(text.dropLast()) }
        else { return "" }
      }
      return ""
    }()
    let style: UIFont.TextStyle = {
      if (0...15).contains(word.count) { return .largeTitle }
      else if (16...18).contains(word.count) { return .title1 }
      else { return .title2 }
    }()
    
    UIView.animate(withDuration: 0.30) {
      self.guessLabel.font = .preferredFont(forTextStyle: style)
      self.guessLabel.text = word.count > 22 ? "" : word
      self.view.layoutIfNeeded()
    }
  }
  
}

//
//  ViewController.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-06-14.
//

import UIKit
import Foundation
import AVFoundation
import CoreData
import SafariServices
import BuyMeACoffee
import Network

class MainViewController: UIViewController {
  
  let networkMonitor = NWPathMonitor()
  var isInternetAvailable = false
  
  var container: NSPersistentContainer? = AppDelegate.persistentContainer
  var fetchedWord: ManagedWord?
  var level: Level = .citizen
  
  //tracking the display of correct word in the collection view to be followed by heartImage
  var isFirstLoadWordSection = true
  var isFirstLoadDefinitionSection = true
  var isLiked = false
  var isFromSpeechService = false
  var didChangeDiction = false
  var answerSubmitted = false
  var animationsPlaying = false
  
  var country: Country = .US
  var keyboardOption: KeyboardOption = .keyboard
  var definition = [String: String]()
  var partOfSpeech = [String]()
  var shuffledWord = [[String]]()
  var concealedWord = [[String]]()
  
  var word: Word? {
    didSet {
      guard !didChangeDiction else { return }
      guard let word = self.word else {
        shuffledWord = [[String]](repeating: [String](), count: 3)
        concealedWord = [[String]](repeating: [String](), count: 3)
        return
      }
      for (partOfSpeech, _) in word.definition {
        self.partOfSpeech.append(partOfSpeech)
      }
      shuffledWord = Keyboard.getShuffledWord(for: word.text)
      concealedWord = Keyboard.getConcealedWord(word: word.text)
    }
  }
  
  var definitionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var keyboardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
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
  lazy var keyboardBlackViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardTapped))
  let keyboardBlackView: UIView = {
    let v = UIView()
    v.backgroundColor = .black
    v.alpha = 0
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  lazy var levelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(launchLevelMenu))
  let levelView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.layer.cornerRadius = 5
    v.backgroundColor = Color.buttonColorBackground
    v.layer.masksToBounds = false
    v.layer.shadowRadius = 2
    v.layer.shadowColor = Color.textColor.cgColor
    v.layer.shadowOpacity = 0.5
    v.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    return v
  }()
  lazy var levelLabel: UILabel = {
    let lbl = UIPaddedLabel(top: 3, bottom: 3, left: 6, right: 6)
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.text = self.level.rawValue.uppercased()
    lbl.font = .preferredFont(forTextStyle: .headline)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textColor = Color.buttonColorText
    lbl.textAlignment = .center
    lbl.isUserInteractionEnabled = true
    return lbl
  }()
  lazy var playTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playAudio))
  let audioImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.image?.withRenderingMode(.alwaysTemplate)
    iv.contentMode = .scaleAspectFit
    iv.tintColor = Color.buttonColorText
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
    s.tintColor = Color.textColor
    return s
  }()
  var keyboardPosition = CGPoint(x: 0, y: 0)
  lazy var keyboardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragKeyboard))
  lazy var keyboardTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardTapped))
  let keyboardView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.layer.cornerRadius = 5
    v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    v.backgroundColor = Color.buttonColorBackground
    v.isUserInteractionEnabled = true
    v.layer.masksToBounds = false
    v.layer.shadowRadius = 2
    v.layer.shadowColor = Color.textColor.cgColor
    v.layer.shadowOpacity = 0.5
    v.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    return v
  }()
  lazy var keyboardImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.heightAnchor.constraint(equalToConstant: keyboardSegmentedControl.intrinsicContentSize.height).isActive = true
    iv.contentMode = .scaleAspectFit
    iv.image = UIImage(named: "keyboard")
    iv.image?.withRenderingMode(.alwaysTemplate)
    iv.tintColor = Color.buttonColorText
    iv.isUserInteractionEnabled = true
    iv.setContentHuggingPriority(.required, for: .horizontal)
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
  var keyboardViewIsOpen = false
  var keyboardViewWidthConstraint: NSLayoutConstraint!
  var keyboardSegmentedControlWidth: CGFloat!
  var keyboardImageViewWidth: CGFloat!
  let keyboardSegmentedControl: UISegmentedControl = {
    let items = ["Keyboard","Shuffled","Concealed"]
    let sc = UISegmentedControl(items: items)
    let font = UIFont.preferredFont(forTextStyle: .body)
    sc.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: Color.textColor], for: .normal)
    sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.screenColor], for: .selected)
    sc.apportionsSegmentWidthsByContent = true
    sc.isHidden = true
    sc.addTarget(self, action: #selector(keyboardChanged(_:)), for: .valueChanged)
    sc.selectedSegmentTintColor = Color.textColor
    sc.backgroundColor = Color.screenColor
    return sc
  }()
  let dictionButton: UIButton = {
    let btn = UIButton()
    btn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.contentMode = .scaleAspectFit
    btn.setTitleColor(Color.buttonColorText, for: .normal)
    btn.addTarget(self, action: #selector(changeDiction(_:)), for: .touchUpInside)
    btn.backgroundColor = Color.buttonColorBackground
    btn.layer.cornerRadius = 5
    btn.layer.masksToBounds = false
    btn.layer.shadowRadius = 2
    btn.layer.shadowColor = Color.textColor.cgColor
    btn.layer.shadowOpacity = 0.5
    btn.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    btn.contentEdgeInsets = .init(top: 3, left: 6, bottom: 3, right: 6)
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
    lbl.adjustsFontSizeToFitWidth = true
    lbl.textAlignment = .center
    return lbl
  }()
  let nextAndSubmitButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Submit", for: .normal)
    btn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.isHidden = true
    btn.addTarget(self, action: #selector(fetchNextSubmitWord(_:)), for: .touchUpInside)
    btn.setTitleColor(Color.buttonColorText, for: .normal)
    btn.backgroundColor = Color.buttonColorBackground
    btn.layer.cornerRadius = 5
    btn.layer.masksToBounds = false
    btn.layer.shadowRadius = 2
    btn.layer.shadowColor = Color.textColor.cgColor
    btn.layer.shadowOpacity = 0.5
    btn.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    btn.contentEdgeInsets = .init(top: 9, left: 9, bottom: 9, right: 9)
    return btn
  }()
  lazy var profileTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewProfile))
  let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.image = UIImage(named: "profile")
    iv.contentMode = .scaleAspectFit
    iv.image?.withRenderingMode(.alwaysTemplate)
    iv.tintColor = Color.textColor
    iv.isUserInteractionEnabled = true
    return iv
  }()
  lazy var infoLabelHeight = infoLabel.intrinsicContentSize.height
  lazy var infoLabelView: UIView = {
    let v = UIView()
    v.frame = infoLabelShadowView.bounds
    v.translatesAutoresizingMaskIntoConstraints = false
    v.heightAnchor.constraint(equalToConstant: infoLabelHeight).isActive = true
    v.widthAnchor.constraint(equalTo: v.heightAnchor, multiplier: 1).isActive = true
    v.layer.cornerRadius = infoLabelHeight / 2.0
    v.layer.masksToBounds = true
    return v
  }()
  lazy var infoLabeTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(launchInfoView))
  lazy var infoLabelShadowView: UIView = {
    let infoLabelHeight = infoLabel.intrinsicContentSize.height
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.heightAnchor.constraint(equalToConstant: infoLabelHeight).isActive = true
    v.widthAnchor.constraint(equalTo: v.heightAnchor, multiplier: 1).isActive = true
    v.backgroundColor = UIColor.clear
    v.layer.masksToBounds = false
    v.layer.shadowRadius = 2
    v.layer.shadowColor = Color.textColor.cgColor
    v.layer.shadowOpacity = 0.5
    v.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    return v
  }()
  let infoLabel: UIPaddedLabel = {
    let lbl = UIPaddedLabel(top: 3, bottom: 3, left: 0, right: 0)
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.text = "❔"
    lbl.font = UIFont.preferredFont(forTextStyle: .title3)
    lbl.adjustsFontSizeToFitWidth = true
    lbl.backgroundColor = Color.buttonColorText
    lbl.textAlignment = .center
    return lbl
  }()
  
  let infoLauncher = InfoLauncher()
  
  @objc func launchInfoView() {
    UIView.animate(withDuration: 0.20) { [weak self] in
      self?.infoLabelShadowView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) { [weak self] in
        self?.infoLabelShadowView.transform = .identity
      } completion: { [weak self] (_) in
        self?.infoLauncher.showInfo()
      }
    }
  }
  
  @objc func viewProfile() {
    UIView.animate(withDuration: 0.20) { [weak self] in
      self?.profileImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) { [weak self] in
        self?.profileImageView.transform = .identity
      } completion: { [weak self] (_) in
        let profileVC = ProfileTableViewController()
        profileVC.delegate = self
        profileVC.currentWord = self?.fetchedWord?.text
        self?.present(UINavigationController(rootViewController: profileVC), animated: true, completion: nil)
      }
    }
  }
  
  private func isWordFetchSuccessful() -> Bool {
    guard let context = container?.viewContext else { return false }
    
    fetchedWord = AppSettings.word.isEmpty
      ? try? ManagedWord.fetchWord(in: context)
      : try? ManagedWord.findWord(AppSettings.word, in: context)
    
    return fetchedWord != nil
  }
  
  private func loadUserDefaults() {
    //language
    let language = AppSettings.language.replacingOccurrences(of: "en_", with: "")
    dictionButton.setTitle(language == "GB" ? "UK" : language, for: .normal)
    country = Country(rawValue: AppSettings.language) ?? .US
    //level
    levelLabel.text = AppSettings.level.uppercased()
    level = Level(rawValue: AppSettings.level) ?? .tourist
    //volume
    volumeSlider.value = AppSettings.volume
    if volumeSlider.value == 0.0 {
      audioImageView.image = UIImage(named: "muted")
      audioImageView.isUserInteractionEnabled = false
      isAudioMuted = true
    } else {
      audioImageView.image = UIImage(named: "audio")
      audioImageView.isUserInteractionEnabled = true
      isAudioMuted = false
    }
    //keyboard
    keyboardOption = KeyboardOption(rawValue: AppSettings.keyboard) ?? .keyboard
    keyboardSegmentedControl.selectedSegmentIndex = keyboardOption.rawValue
    //spelling counts
    guard AppSettings.isFirstLoad, let context = container?.viewContext else { return }
    context.perform {
      Level.allCases.forEach {
        do {
          let count = try ManagedWord.getCount(for: $0, in: context)
          switch $0 {
          case .tourist: AppSettings.touristSpellCount = count
          case .immigrant: AppSettings.immigrantSpellCount = count
          case .citizen: AppSettings.citizenSpellCount = count
          case .president: AppSettings.presidentSpellCount = count
          }
        } catch {
          print(error)
        }
      }
      
    }
  }
  
  let spinnerVC = SpinnerViewController()
  func createSpinnerView() {
    self.addChild(spinnerVC)
    spinnerVC.view.frame = view.convert(definitionView.bounds, from: definitionView)
    view.addSubview(spinnerVC.view)
    spinnerVC.didMove(toParent: self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard isInternetAvailable, AppSettings.isFirstLoad else { return }
    createSpinnerView()
    AppSettings.isFirstLoad = false
  }
  
  //Use this code to preload CoreData
  //    if let context = container?.viewContext {
  //      ManagedWord.preloadData(in: context)
  //    }
  fileprivate func monitorInternetStatus() {
    let queue = DispatchQueue(label: "Monitor")
    
    networkMonitor.pathUpdateHandler = { [unowned self] path in
      isInternetAvailable = path.status == .satisfied
    }
    networkMonitor.start(queue: queue)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Color.screenColor
    monitorInternetStatus()
    loadUserDefaults()
    
    guard isWordFetchSuccessful(), let text = fetchedWord?.text else { return }
    AppSettings.word = text
    print(text)
    fetchWordAPI(with: country) {(successful) in
      DispatchQueue.main.async { [weak self] in
        //self?.isFromSpeechService = !successful
        self?.isFromSpeechService = true
        if !successful {
          self?.word = Word(text: text, definition: self!.definition, audio: nil)
        }
        self?.definitionCollectionView.delegate = self
        self?.definitionCollectionView.dataSource = self
        self?.keyboardCollectionView.delegate = self
        self?.keyboardCollectionView.dataSource = self
        
        self?.definitionCollectionView.collectionViewLayout = self!.generateDefinitionLayout()
        self?.keyboardCollectionView.collectionViewLayout = self!.generateKeyboardLayout()
        self?.changeUIStateAfterFetch(true)
        UIView.animate(withDuration: 0.50) { [weak self] in
          self?.definitionCollectionView.reloadData()
          self?.keyboardCollectionView.reloadData()
          self?.keyboardCollectionView.isScrollEnabled = false
        }
        self?.spinnerVC.willMove(toParent: nil)
        self?.spinnerVC.view.removeFromSuperview()
        self?.spinnerVC.removeFromParent()
      }
    }
    
    definitionCollectionView.register(DefinitionCollectionViewCell.self, forCellWithReuseIdentifier: DefinitionCollectionViewCell.reuseIdentifier)
    definitionCollectionView.register(WordCollectionViewCell.self, forCellWithReuseIdentifier: WordCollectionViewCell.reuseIdentifier)
    keyboardCollectionView.register(KeyboardCollectionViewCell.self, forCellWithReuseIdentifier: KeyboardCollectionViewCell.reuseIdentifier)
    definitionCollectionView.backgroundColor = Color.screenColor
    keyboardCollectionView.backgroundColor = Color.screenColor
    
    setupViewLayout()
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateUIState), name: .playbackEnded, object: nil)
    BMCManager.shared.presentingViewController = self
  }
  
  override func viewDidLayoutSubviews() {
    if keyboardSegmentedControlWidth == nil {
      keyboardSegmentedControlWidth = keyboardSegmentedControl.frame.size.width
    }
    if keyboardImageViewWidth == nil || keyboardImageViewWidth == 0.0 {
      keyboardImageViewWidth = keyboardImageView.frame.size.width
    }
  }
  
  lazy var levelMenuLauncher: LevelMenuLauncher = {
    let launcher = LevelMenuLauncher()
    launcher.delegate = self
    return launcher
  }()
  
  @objc func launchLevelMenu() {
    guard answerSubmitted && !animationsPlaying else { return }
    
    UIView.animate(withDuration: 0.10) {
      self.levelView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        self.levelView.transform = .identity
      } completion: { (_) in
        self.levelMenuLauncher.showMenu()
      }
    }
    
  }
  
  private func generateDefinitionLayout() -> UICollectionViewLayout {
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
    view.addSubview(nextAndSubmitButton)
    view.addSubview(keyboardSectionView)
    view.addSubview(profileImageView)
    view.addSubview(infoLabelShadowView)
    view.addSubview(keyboardBlackView)
    view.addSubview(keyboardView)
    
    let viewHeight = view.safeAreaLayoutGuide.layoutFrame.size.height
    let topViewTopAnchor = viewHeight * 0.01
    let definitionViewTopAnchor = viewHeight * 0.01
    let audioVStackViewTopAnchor = viewHeight * 0.03
    let guessLabelViewTopAnchor = viewHeight * 0.03
    let keyboardSectionViewTopAnchor = viewHeight * 0.03
    let submitButtonTopAnchor = viewHeight * 0.03
    
    audioImageView.addGestureRecognizer(playTapRecognizer)
    profileImageView.addGestureRecognizer(profileTapRecognizer)
    levelView.addGestureRecognizer(levelTapRecognizer)
    keyboardBlackView.addGestureRecognizer(keyboardBlackViewTapRecognizer)
    infoLabelShadowView.addGestureRecognizer(infoLabeTapRecognizer)
    
    topView.addSubview(dictionButton)
    dictionButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 8).isActive = true
    dictionButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    
    levelView.addSubview(levelLabel)
    levelLabel.matchParent()
    
    topView.addSubview(levelView)
    levelView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
    levelView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
    levelView.heightAnchor.constraint(equalTo: dictionButton.heightAnchor).isActive = true
    
    topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topViewTopAnchor).isActive = true
    topView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
    topView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
    topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    definitionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: definitionViewTopAnchor).isActive = true
    definitionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive = true
    definitionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.30).isActive = true
    definitionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    definitionView.addSubview(definitionCollectionView)
    definitionCollectionView.translatesAutoresizingMaskIntoConstraints = false
    definitionCollectionView.matchSize()
    
    audioImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.07).isActive = true
    audioImageView.widthAnchor.constraint(equalTo: audioImageView.heightAnchor, multiplier: 1).isActive = true
    audioVStackView.topAnchor.constraint(equalTo: definitionCollectionView.bottomAnchor, constant: audioVStackViewTopAnchor).isActive = true
    audioVStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    guessLabelView.topAnchor.constraint(equalTo: audioVStackView.bottomAnchor, constant: guessLabelViewTopAnchor).isActive = true
    guessLabelView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.08).isActive = true
    guessLabelView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1).isActive = true
    guessLabelView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    guessLabelView.addSubview(guessLabel)
    guessLabel.leadingAnchor.constraint(equalTo: guessLabelView.leadingAnchor, constant: 10).isActive = true
    guessLabel.trailingAnchor.constraint(equalTo: guessLabelView.trailingAnchor, constant: -10).isActive = true
    guessLabel.centerYAnchor.constraint(equalTo: guessLabelView.centerYAnchor).isActive = true
    
    keyboardSectionView.topAnchor.constraint(equalTo: guessLabelView.bottomAnchor, constant: keyboardSectionViewTopAnchor).isActive = true
    keyboardSectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
    keyboardSectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.20).isActive = true
    keyboardSectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    keyboardSectionView.addSubview(keyboardCollectionView)
    keyboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
    keyboardCollectionView.matchSize()
    keyboardBlackView.matchParent()
    
    keyboardViewWidthConstraint = NSLayoutConstraint(
      item: keyboardView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: keyboardImageView.intrinsicContentSize.width * 1.8)
    keyboardView.addConstraint(keyboardViewWidthConstraint)
    
    keyboardView.addGestureRecognizer(keyboardTapRecognizer)
    keyboardView.addGestureRecognizer(keyboardPanRecognizer)
    keyboardView.bottomAnchor.constraint(equalTo: keyboardSectionView.topAnchor, constant: -2).isActive = true
    keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    keyboardView.heightAnchor.constraint(equalToConstant: keyboardSegmentedControl.intrinsicContentSize.height + 5).isActive = true
    
    keyboardView.addSubview(keyboardHStackView)
    keyboardHStackView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -5).isActive = true
    keyboardHStackView.centerYAnchor.constraint(equalTo: keyboardView.centerYAnchor).isActive = true
    keyboardHStackView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 0).isActive = true
    
    nextAndSubmitButton.topAnchor.constraint(equalTo: keyboardSectionView.bottomAnchor, constant: submitButtonTopAnchor).isActive = true
    nextAndSubmitButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    let width = view.frame.size.width
    let padding = (width - (width * 0.95)) / 2 //relative to topView
    profileImageView.leadingAnchor.constraint(equalTo: dictionButton.leadingAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding - 8).isActive = true
    profileImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true
    profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1).isActive = true
    
    infoLabelShadowView.trailingAnchor.constraint(equalTo: levelView.trailingAnchor).isActive = true
    infoLabelShadowView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    
    
    infoLabelShadowView.addSubview(infoLabelView)
    infoLabelView.centerXYin(infoLabelShadowView)
    
    infoLabelView.addSubview(infoLabel)
    infoLabel.matchParent()
  }
  
  func initPlayer() {
    guard let word = word, let audio = word.audio else { return }
    AudioPlayer.shared.initPlayer(with: audio)
  }
  
  @objc func keyboardChanged(_ sender: UISegmentedControl) {
    keyboardTapped()
    
    guard let option = KeyboardOption(rawValue: sender.selectedSegmentIndex) else { return }
    keyboardOption = option
    AppSettings.keyboard = keyboardOption.rawValue
    UIView.animate(withDuration: 0.5) { [weak self] in
      self?.keyboardCollectionView.reloadData()
    }
  }
  
  
  @objc func keyboardTapped() {
    keyboardViewIsOpen.toggle()
    keyboardView.removeConstraint(keyboardViewWidthConstraint)
    
    let constant = keyboardViewIsOpen
      ? keyboardImageView.intrinsicContentSize.width + keyboardSegmentedControl.intrinsicContentSize.width
      : (keyboardImageViewWidth ?? 0.0)
    
    UIView.animate(withDuration: 0.40) { [weak self] in
      self?.keyboardBlackView.alpha = self!.keyboardViewIsOpen ? 0.7 : 0.0
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
      
      guard keyboardPosition.y < -60 || keyboardPosition.y > 180 else { return }
      if keyboardPosition.y < -60 { keyboardPosition.y = -60 }
      else if keyboardPosition.y > 180 { keyboardPosition.y = 180 }
      
      UIView.animate(withDuration: 0.5,
                     delay: 0,
                     usingSpringWithDamping: 1,
                     initialSpringVelocity: 1,
                     options: .curveEaseIn,
                     animations: { [weak self] in
                      self?.keyboardView.transform = CGAffineTransform(translationX: 0, y: self!.keyboardPosition.y)
                     })
    }
  }
  
  @objc func playAudio() {
    updateUIState()
    if isFromSpeechService {
      guard let text = word?.text else { return }
      let language = country.rawValue.replacingOccurrences(of: "_", with: "-")
      SpeechService.shared.say(text, in: language, volume: volumeSlider.value)
    } else {
      AudioPlayer.shared.play()
    }
  }
  
  @objc func adjustVolume(_ sender: UISlider) {
    AppSettings.volume = sender.value
    
    sender.alpha = 0.20
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
    setPlayImageViewColor()
    if isFromSpeechService { SpeechService.shared.setVolume(to: sender.value) }
    else { AudioPlayer.shared.setVolume(to: sender.value) }
    if sender.value > 0.0 { playAudio() }
  }
  
  @objc func changeSlider(_ sender: UISlider) {
    sender.alpha = 0.80
    UIView.animate(withDuration: 0.30) { sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }
  }
  
  func changeUIStateAfterFetch(_ successful: Bool) {
    audioImageView.isUserInteractionEnabled = !isAudioMuted
    keyboardView.isUserInteractionEnabled = !answerSubmitted
    setPlayImageViewColor()
    
    if volumeSlider.value > 0.0 { playAudio() }
    
    guard !didChangeDiction else { return }
    nextAndSubmitButton.setTitle(!answerSubmitted ? "Submit" : "Next", for: .normal)
    nextAndSubmitButton.isHidden = !answerSubmitted
  }
  
  @objc func updateUIState() {
    audioImageView.isUserInteractionEnabled.toggle()
    volumeSlider.isUserInteractionEnabled.toggle()
    nextAndSubmitButton.isEnabled.toggle()
    profileImageView.isUserInteractionEnabled.toggle()
    definitionCollectionView.isUserInteractionEnabled.toggle()
    dictionButton.isUserInteractionEnabled.toggle()
    levelLabel.isUserInteractionEnabled.toggle()
    infoLabelShadowView.isUserInteractionEnabled.toggle()
    
    if animationsPlaying { setPlayImageViewColor()
      return
    }
    
    if audioImageView.isUserInteractionEnabled {
      UIView.animate(withDuration: 0.10) { [weak self] in
        self?.setPlayImageViewColor()
        self?.audioImageView.transform = .identity
      }
    } else {
      UIView.animate(withDuration: 0.50) { [weak self] in
        self?.setPlayImageViewColor()
        self?.audioImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      }
    }
    
    guard !answerSubmitted else { return }
    
    keyboardView.isUserInteractionEnabled.toggle()
    keyboardCollectionView.isUserInteractionEnabled.toggle()
  }
  
  fileprivate func setPlayImageViewColor() {
    UIView.transition(with: audioImageView, duration: 0.5, options: .transitionCrossDissolve) { [weak self] in
      self?.audioImageView.tintColor = self!.audioImageView.isUserInteractionEnabled ? Color.textColor : Color.buttonColorBackground
    }
  }
  
  fileprivate func reloadDefinition(completion: @escaping (_ completed: Bool) -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock { completion(true) }
    if partOfSpeech.isEmpty {
      definitionCollectionView.reloadItems(at: [IndexPath(item: 0, section: 1)])
    }
    CATransaction.commit()
  }
  
  fileprivate func showHeartButton(completion: @escaping (_ completed: Bool) -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock { completion(true) }
    definitionCollectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    definitionCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    CATransaction.commit()
  }
  
  fileprivate func showCorrectWord(completion: @escaping (_ completed: Bool) -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.isFirstLoadWordSection = false
      completion(true)
    }
    definitionCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    CATransaction.commit()
  }
  
  @objc func fetchNextSubmitWord(_ sender: UIButton) {
    sender.isEnabled = false
    UIView.animate(withDuration: 0.10) {
      sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.10) {
        sender.transform = .identity
      } completion: { (_) in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
          if sender.title(for: .normal) == "Submit" {
            AppSettings.word.removeAll()
            answerSubmitted = true
            isFirstLoadWordSection = true
            keyboardCollectionView.isUserInteractionEnabled = false
            keyboardView.isUserInteractionEnabled = false
            animationsPlaying = true
            updateUIState()
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve) {
              sender.alpha = 0
            }
            
            showCorrectWord { (completed) in
              if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                  self?.showHeartButton { (completed) in
                    if completed {
                      self?.checkAnswer { (completed) in
                        if completed {
                          container?.performBackgroundTask({ (context) in
                            do {
                              let count = try ManagedWord.getCount(for: level, in: context)
                              switch level {
                              case .tourist: AppSettings.touristSpellCount = count
                              case .immigrant: AppSettings.immigrantSpellCount = count
                              case .citizen: AppSettings.citizenSpellCount = count
                              case .president: AppSettings.presidentSpellCount = count
                              }
                            } catch {
                              print(error)
                            }
                          })
                          self?.isFirstLoadDefinitionSection = false
                          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) { [weak self] in
                            self?.reloadDefinition { (completed) in
                              if completed {
                                self?.updateUIState()
                                NotificationCenter.default.post(name: .animationsEnded, object: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                  UIView.transition(with: sender, duration: 1.0, options: .transitionCrossDissolve) {
                                    sender.setTitle("Next", for: .normal)
                                    sender.alpha = 1.0
                                    sender.isEnabled.toggle()
                                  } completion: { (_) in
                                    self?.animationsPlaying.toggle()
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          } else {
            view.superview?.isUserInteractionEnabled = false
            createSpinnerView()
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve) {
              sender.alpha = 0
            } completion: { (_) in
              sender.isEnabled.toggle()
            }
            guessLabel.alpha = 1.0
            keyboardCollectionView.isUserInteractionEnabled = true
            answerSubmitted = false
            isLiked = false
            didChangeDiction = false
            partOfSpeech.removeAll()
            guessLabel.text?.removeAll()
            isFirstLoadDefinitionSection = true
            WordCollectionViewCell.allAnimationsLoaded = nil
            DefinitionCollectionViewCell.isFirstLoadDone = nil
            
            guard isWordFetchSuccessful(), let text = fetchedWord?.text else { return }
            AppSettings.word = text
            print(AppSettings.word)
            
            fetchWordAPI(with: country) { (successful) in
              DispatchQueue.main.async { [weak self] in
                if !successful {
                  self?.word = Word(text: text, definition: self!.definition, audio: nil)
                }
                //for use when audio from API is available
                //self?.isFromSpeechService = !successful
                self?.isFromSpeechService = true
                self?.changeUIStateAfterFetch(true)
                self?.definitionCollectionView.reloadData()
                self?.definitionCollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: false)
                
                if self!.keyboardOption != .keyboard { self?.keyboardCollectionView.reloadData() }
                
                self?.spinnerVC.willMove(toParent: nil)
                self?.spinnerVC.view.removeFromSuperview()
                self?.spinnerVC.removeFromParent()
                self?.view.superview?.isUserInteractionEnabled.toggle()
              }
            }
          }
        }
      }
    }
  }
  
  private func checkAnswer(completion: @escaping (_ completed: Bool) -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock { completion(true) }
    
    guard let text = fetchedWord?.text, let context = container?.viewContext else { return }
    let isCorrect = text == guessLabel.text
    
    //frc deletes the entry from the tableview if the state update is performed in the background thread.
    context.perform {
      let word = try? ManagedWord.findWord(text, in: context)
      word?.state = isCorrect ? .spelled : .misspelled
      try? context.save()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
      if isCorrect {
        UIView.transition(with: guessLabel, duration: 0.8, options: .transitionFlipFromTop) { [weak self] in
          UIView.animate(withDuration: 0.10) {
            self?.guessLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
          } completion: { (_) in
            UIView.animate(withDuration: 0.20) {
              self?.guessLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { (_) in
              UIView.animate(withDuration: 0.5) {
                self?.guessLabel.transform = .identity
              }
            }
          }
        }
      } else {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.5) {
              self.guessLabel.alpha = 0.5
            }
          }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [unowned self] in
          let animation = CABasicAnimation(keyPath: "position")
          animation.duration = 0.05
          animation.repeatCount = 4
          animation.autoreverses = true
          animation.fromValue = NSValue(cgPoint: CGPoint(x: self.guessLabel.center.x - 12, y: self.guessLabel.center.y))
          animation.toValue = NSValue(cgPoint: CGPoint(x: self.guessLabel.center.x + 12, y: self.guessLabel.center.y))
          self.guessLabel.layer.add(animation, forKey: "position")
        }
        CATransaction.commit()
      }
    }
    CATransaction.commit()
  }
  
  @objc func changeDiction(_ sender: UIButton) {
    guard !animationsPlaying else { return }
    
    let title = sender.title(for: .normal) == "US" ? "UK" : "US"
    
    country.toggle()
    AppSettings.language = country.rawValue
    
    didChangeDiction = true
    sender.layer.shadowOpacity = 0
    
    UIView.animate(withDuration: 0.15) {
      sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    } completion: { (_) in
      UIView.animate(withDuration: 0.15) {
        sender.transform = .identity
      } completion: { (_) in
        UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromTop) {
          sender.setTitle(title, for: .normal)
          sender.layer.shadowOpacity = 0.5
        } completion: { (_) in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard !self!.isFromSpeechService else {
              self?.changeUIStateAfterFetch(true)
              return
            }
            self?.fetchWordAPI(with: self!.country) { [weak self] (successful) in
              //some words don't have both diction available
              if successful { self?.changeUIStateAfterFetch(successful) }
            }
          }
        }
      }
    }
    
  }
  
  fileprivate func fetchWordAPI(with country: Country, completion: @escaping (Bool) -> Void) {
    guard let text = fetchedWord?.text else { return }
    WordInfoAPI.shared.fetchWordInfoAPI(word: text, country: country) { (result) in
      DispatchQueue.main.async { [weak self] in
        self?.definition.removeAll()
        
        switch result {
        case .failure(let error):
          completion(false)
          print(error.localizedDescription)
        case .success(let word):
          if let item = word.first {
            for meaning in item.meanings {
              if let definitionAPI = meaning.definitions.first?.definition {
                let definition = Word.maskWord(text, from: definitionAPI)
                self?.definition.updateValue(definition, forKey: meaning.partOfSpeech + ":")
              }
            }
            print("fetched from API \(item.word)")
            let fetchedWord = item.word.replacingOccurrences(of: "-", with: "").lowercased()
            
            guard let text = self?.fetchedWord?.text, text == fetchedWord else {
              completion(false)
              return
            }
            if let _ = item.phonetics.first?.audio {
              self?.word = Word(text: fetchedWord, definition: self!.definition, audio: nil)
              //if audio is available from API
              //self?.initPlayer()
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
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == keyboardCollectionView { return 3 }
    else if collectionView == definitionCollectionView { return 2 }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIndex: Int) -> Int {
    if collectionView == definitionCollectionView {
      if sectionIndex == 0 { return answerSubmitted ? 1 : 0 }
      else {
        if let word = word { return word.definition.count == 0 ? 1 : word.definition.count }
        return 1 //to display the error message as an item
      }
    } else {
      if word == nil { return 0 }
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
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == definitionCollectionView {
      if indexPath.section == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordCollectionViewCell.reuseIdentifier, for: indexPath) as! WordCollectionViewCell
        
        cell.heartImageView.isHidden = true
        cell.liked = isLiked ? .liked : .unliked
        cell.delegate = self
        cell.searchInSafari = { [weak self] in
          self?.searchInSafari()
        }
        
        guard let text = word?.text else { return cell }
        
        if isFirstLoadWordSection {
          UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, animations: {
            AnimationUtility.viewSlideInFromTop(toBottom: cell)
          })
        } else {
          UIView.transition(with: cell.heartImageView, duration: 0.9, options: .transitionFlipFromRight) {
            cell.heartImageView.isHidden = false
          } completion: { (_) in
            UIView.transition(with: cell.heartImageView, duration: 0.9, options: .transitionFlipFromLeft) {
            }
          }
        }
        NotificationCenter.default.removeObserver(cell, name: .animationsEnded, object: nil)
        if !isFirstLoadDefinitionSection && partOfSpeech.isEmpty {
          NotificationCenter.default.addObserver(cell, selector: #selector(WordCollectionViewCell.animationsEnded), name: .animationsEnded, object: nil)
        }
        cell.setup(with: text)
        return cell
      } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefinitionCollectionViewCell.reuseIdentifier, for: indexPath) as! DefinitionCollectionViewCell
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, animations: {
          AnimationUtility.viewSlideInFromTop(toBottom: cell)
        })
        
        guard let word = word?.definition
        else {
          cell.setup(with: "Error:", and: "Please press next")
          return cell
        }
        if partOfSpeech.count == 0 {
          if isFirstLoadDefinitionSection {
            cell.setup(with: "", and: "Sorry, no definition available.")
          } else {
            DefinitionCollectionViewCell.isFirstLoadDone = true
            cell.setup(with: "", and: "Tap the word for definition")
          }
          return cell
        }
        let partofSpeech = partOfSpeech[indexPath.item]
        guard let definition = word[partofSpeech] else { return cell }
        cell.setup(with: partofSpeech, and: definition)
        return cell
      }
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardCollectionViewCell
      
      UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
        if indexPath.section == 0 { AnimationUtility.viewSlideInFromTop(toBottom: cell) }
        else if indexPath.section == 1 { AnimationUtility.viewSlideInFromRight(toLeft: cell) }
        else { AnimationUtility.viewSlideInFromBottom(toTop: cell) }
      })
      
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
    if collectionView == definitionCollectionView {
      cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      UIView.animate(withDuration: 0.25) { cell.transform = .identity }
    }
  }
  
  private func searchInSafari() {
    guard let url = word?.searchURL else { return }
    let safariVC = SFSafariViewController(url: url)
    self.present(safariVC, animated: true)
  }
  
}

// MARK: - KeyboardCollectionViewCellDelegate
extension MainViewController: KeyboardCollectionViewCellDelegate {
  func keyPressed(for key: String) {
    guard let _ = word?.text else { return }
    let word: String = {
      guard let text = guessLabel.text else { return "" }
      if key.count == 1 { return text + key }
      else if key == "DEL" { return String(text.dropLast()) }
      else { return "" }
    }()
    
    UIView.animate(withDuration: 0.30) { [weak self] in
      self?.guessLabel.text = word.count > 22 ? "" : word
      self?.nextAndSubmitButton.isHidden = word.count < 1//Int(floor(Float(text.count) * 0.90))
      self?.nextAndSubmitButton.alpha = self!.nextAndSubmitButton.isHidden ? 0 : 1
      self?.view.layoutIfNeeded()
    }
  }
  
}

// MARK: - WordCollectionViewCellDelegate
extension MainViewController: WordCollectionViewCellDelegate {
  func isWordLiked(status: Bool) {
    
    guard let context = container?.viewContext, let text = fetchedWord?.text else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.isLiked = status
      self?.fetchedWord = try? ManagedWord.findWord(text, in: context)
      self?.fetchedWord?.isFavorite = self!.isLiked
      try? context.save()
    }
  }
  
}

extension MainViewController: LevelMenuLauncherDelegate {
  func changeLevel(to level: Level) {
    guard self.level != level else { return }
    self.level = level
    AppSettings.level = level.rawValue
    
    UIView.transition(with: levelView, duration: 0.5, options: .transitionFlipFromTop) {
      self.levelLabel.text = self.level.rawValue.uppercased()
    }
  }
}

extension MainViewController: ProfileTableViewControllerDelegate {
  func favoriteStatusChanged() {
    guard answerSubmitted else { return }
    isLiked.toggle()
    definitionCollectionView.reloadSections([0])
  }
}

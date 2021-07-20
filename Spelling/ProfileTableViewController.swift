//
//  ProfileTableViewController.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-19.
//

import UIKit
import CoreData

class ProfileTableViewController: FetchedResultsTableViewController, UIGestureRecognizerDelegate {
  
  var filter: Filter = .spelled
  var predicate: NSPredicate {
    let status = filter == .spelled ? 1 : 2
    let filterPredicate = filter == .favorites
      ? NSPredicate(format: "isFavorite == true")
      : NSPredicate(format: "status == \(status)")
    return filterPredicate
  }
  var request: NSFetchRequest<ManagedWord> {
    let request: NSFetchRequest<ManagedWord> = ManagedWord.fetchRequest()
    request.predicate = predicate
    request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
    request.fetchBatchSize = 40
    return request
  }
  var container: NSPersistentContainer = AppDelegate.persistentContainer
  lazy var fetchedResultsController: NSFetchedResultsController<ManagedWord> = {
    let frc = NSFetchedResultsController<ManagedWord>(
      fetchRequest: request,
      managedObjectContext: container.viewContext,
      sectionNameKeyPath: "firstLetter",
      cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
  lazy var countSegmentedControl: UISegmentedControl = {
    let items = ["Spelled","Misspelled","Favorites"]
    let sc = UISegmentedControl(items: items)
    let font = UIFont.preferredFont(forTextStyle: .body)
    sc.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
    sc.selectedSegmentIndex = 0
    sc.layer.cornerRadius = 12
    sc.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
    return sc
  }()
  
  let countLabel: UILabel = {
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.font = UIFont.preferredFont(forTextStyle: .caption1)
    lbl.text = ""
    lbl.textAlignment = .center
    lbl.adjustsFontSizeToFitWidth = true
    lbl.setContentHuggingPriority(.required, for: .vertical)
    return lbl
  }()
  
  lazy var hStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [countSegmentedControl, countLabel])
    sv.axis = .vertical
    sv.spacing = 5
    sv.distribution = .fill
    sv.alignment = .center
    return sv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = hStackView
    tableView.register(WordTableViewCell.self, forCellReuseIdentifier: WordTableViewCell.reuseIdentifier)
    filterChanged(self.countSegmentedControl)
  }
  
  @objc func filterChanged(_ sender: UISegmentedControl) {
    guard let title = sender.titleForSegment(at: sender.selectedSegmentIndex) else { return }
    filter = Filter(rawValue: title.lowercased())!
    do {
      fetchedResultsController.fetchRequest.predicate = predicate
      try fetchedResultsController.performFetch()
      tableView.reloadData()
    } catch {
      print("fetch failed")
    }
    
    do {
      guard let count = try? fetchedResultsController.managedObjectContext.count(for: request) else { return }
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      let value = numberFormatter.string(from: NSNumber(value: count))
      
      guard let countsLabel = countLabel.text, countsLabel != value  else { return }
      
      UIView.transition(with: countLabel, duration: 0.5, options: .transitionFlipFromTop) { [weak self] in
        self?.countLabel.text = value
        UIView.animate(withDuration: 0.5) {
          self?.countLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        } completion: { (_) in
          UIView.animate(withDuration: 0.5) { self?.countLabel.transform = .identity }
        }
      }
    }
  }
  
  @objc func heartTapped(_ sender: HeartButton) {
    guard let indexPath = sender.indexPath else { return }

    let word = self.fetchedResultsController.object(at: indexPath)
    UIView.transition(with: sender, duration: 0.4, options: .transitionFlipFromLeft) {
      sender.setImage(UIImage(named: !word.isFavorite ? "heart_filled" : "heart"), for: .normal)
    } completion: { (_) in
      word.isFavorite.toggle()
      try? self.fetchedResultsController.managedObjectContext.save()
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sections = fetchedResultsController.sections, sections.count > 0 {
      return sections[section].numberOfObjects
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.reuseIdentifier, for: indexPath) as! WordTableViewCell
    
    let word = fetchedResultsController.object(at: indexPath)
    let button = HeartButton(type: .custom)
    button.indexPath = indexPath
    button.setImage(UIImage(named: word.isFavorite ? "heart_filled" : "heart"), for: .normal)
    button.sizeToFit()
    button.addTarget(self, action: #selector(heartTapped(_:)), for: .touchUpInside)
    cell.accessoryView = button
    cell.textLabel?.text = word.text
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let sections = fetchedResultsController.sections, sections.count > 0 {
      return sections[section].name.uppercased()
    }
    return nil
  }
  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return fetchedResultsController.sectionIndexTitles
  }
  override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
  }
}
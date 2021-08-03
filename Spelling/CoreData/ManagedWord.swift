//
//  ManagedWord.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-15.
//

import Foundation
import CoreData

class ManagedWord: NSManagedObject {
  
  private static let request: NSFetchRequest<ManagedWord> = ManagedWord.fetchRequest()
  private static let notSpelledPredicate = NSPredicate(format: "status != 1")
  private static var wordLengthPredicate: NSPredicate {
    let level = Level(rawValue: AppSettings.level)!
    let p = NSPredicate(format: "text MATCHES %@", ".{\(level.range.lowerBound),\(level.range.upperBound)}")
    return p
  }
  
  class func getCount(for level: Level, in context: NSManagedObjectContext) throws -> Int {
    let levelPredicate = NSPredicate(format: "text MATCHES %@", ".{\(level.range.lowerBound),\(level.range.upperBound)}")
    request.predicate = NSCompoundPredicate(type: .and, subpredicates: [notSpelledPredicate, levelPredicate])
    do {
      return try context.fetch(request).count
    } catch {
      print(error)
    }
    return 0
  }
  
  class func findWord(_ text: String, in context: NSManagedObjectContext) throws -> ManagedWord? {
    let predicate = NSPredicate(format: "text LIKE[c] %@", text)
    request.predicate = predicate
    do {
      let words = try context.fetch(request)
      assert(words.count == 1, "ManagedWord.findWord: Database inconsistency")
      return words.first
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  fileprivate static func getRandomWord(_ words: [ManagedWord]) -> ManagedWord? {
    let count = UInt32(words.count)
    let i = Int(arc4random_uniform(count))
    let word = words[i]
    return word
  }
  
  class func fetchWord(in context: NSManagedObjectContext) throws -> ManagedWord? {
    request.predicate = NSCompoundPredicate(type: .and, subpredicates: [notSpelledPredicate, wordLengthPredicate])
    do {
      let words = try context.fetch(request)
      guard words.count > 1 else {
        request.predicate = wordLengthPredicate
        let words = try context.fetch(request)
        return getRandomWord(words)
      }
      return getRandomWord(words)
      
    } catch {
      print(error)
      throw error
    }
  }
  
  class func getPWord(in context: NSManagedObjectContext) throws -> ManagedWord? {
    let predicate = NSPredicate(format: "text BEGINSWITH %@", "p")
    request.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, wordLengthPredicate])
    do {
      let words = try context.fetch(request)
      return getRandomWord(words)
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  class func preloadData(in context: NSManagedObjectContext) {
    //    let contents = try! String(contentsOfFile: "/Users/macbookpro/Downloads/English/outmod.txt", encoding: .utf8)
    //    let lines = contents.split(separator: "\n")
    //
    //    context.perform {
    //      for line in lines {
    //        let word = ManagedWord(context: context)
    //        word.text = String(line)
    //        word.isFavorite = false
    //        word.state = .def
    //        if let first = line.first { word.firstLetter = String(first) }
    //        try? context.save()
    //      }
    //    }
  }
  
}

extension ManagedWord {
  var state: Status {
    get { return Status(rawValue: self.status) ?? .def }
    set { self.status = newValue.rawValue }
  }
  
  var searchURL: URL? {
    let searchText = "define \(self.text!)"
    let text = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let query = "https://www.google.com/search?q=\(text)"
    return URL(string: query)
  }
}

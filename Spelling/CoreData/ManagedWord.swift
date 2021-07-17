//
//  ManagedWord.swift
//  Spelling
//
//  Created by Gil Jetomo on 2021-07-15.
//

import Foundation
import CoreData

class ManagedWord: NSManagedObject {
  
  class func fetchWord(with level: Level, in context: NSManagedObjectContext) throws -> String? {
    let lowerbound = level.range.lowerBound
    let upperbound = level.range.upperBound
    let request: NSFetchRequest<ManagedWord> = ManagedWord.fetchRequest()
    let notSpelledPredicate = NSPredicate(format: "status != 1")
    let textLengthPredicate = NSPredicate(format: "text MATCHES %@", ".{\(lowerbound),\(upperbound)}")
    let andPredicates = NSCompoundPredicate(type: .and, subpredicates: [notSpelledPredicate, textLengthPredicate])
    request.predicate = andPredicates
    do {
      let words = try context.fetch(request)
      guard words.count > 0 else { return nil }
      let count = UInt32(words.count)
      let i = Int(arc4random_uniform(count))
      let word = words[i]
      print(word.text, word.firstLetter, word.isFavorite, word.state)
      return words[i].text
    } catch {
      print(error)
      throw error
    }
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
}
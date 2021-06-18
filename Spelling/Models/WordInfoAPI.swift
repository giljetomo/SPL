//
//  WordInfoAPI.swift
//  Spelling
//
//  Created by Macbook Pro on 2021-06-14.
//

import Foundation

class WordInfoAPI {
  
  static let shared = WordInfoAPI()
  private var dataTask: URLSessionDataTask?
  
  enum NetworkError: Error {
    case client(message: String)
    case server
  }
  private init() { }
  
  func fetchWordInfoAPI(word: String, country: Country, completion: @escaping (Result<[WordAPI], NetworkError>) -> Void) {
    guard let url = URL(string: Endpoint.baseURL + country.rawValue + "/" + word) else { return }
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
      guard error == nil else {
        completion(.failure(.client(message: "invalid request")))
        return
      }
      guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
        print((response as! HTTPURLResponse).statusCode)
        completion(.failure(.server))
        return
      }
      
      if let data = data {
        do {
          let decoder = JSONDecoder()
          let word = try decoder.decode([WordAPI].self, from: data)
          completion(.success(word))
        } catch {
          completion(.failure(.client(message: error.localizedDescription)))
        }
      }
    }
    task.resume()
  }
}

extension WordInfoAPI.NetworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .server:
      return NSLocalizedString("Server error!", comment: "")
    case .client(let message):
      return NSLocalizedString("Client error! - \(message)", comment: "")
    }
  }
}

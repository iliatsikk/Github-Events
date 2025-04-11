//
//  NetworkError.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

public enum NetworkError: Error, LocalizedError {
  case invalidURL
  case afError(AFError)
  case decodingError(DecodingError)
  case authenticationRequired
  case forbidden
  case notFound
  case serverError
  case unknown(Error)

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid base URL configuration."
    case .afError(let error):
      return "Alamofire error: \(error.localizedDescription)"
    case .decodingError(let error):
      return "Decoding error: \(error.localizedDescription)"
    case .authenticationRequired:
      return "Authentication required for this request."
    case .forbidden:
      return "You don't have permission to access this resource."
    case .notFound:
      return "The requested resource was not found."
    case .serverError:
      return "GitHub server error occurred."
    case .unknown(let error):
      return "Unknown error: \(error.localizedDescription)"
    }
  }
}

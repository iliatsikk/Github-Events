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
    return switch self {
    case .invalidURL: "Invalid base URL configuration."
    case .afError(let error): "Alamofire error: \(error.localizedDescription)"
    case .decodingError(let error): "Decoding error: \(error.localizedDescription)"
    case .authenticationRequired: "Authentication required for this request."
    case .forbidden: "You don't have permission to access this resource."
    case .notFound:  "The requested resource was not found."
    case .serverError: "GitHub server error occurred."
    case .unknown(let error): "Unknown error: \(error.localizedDescription)"
    }
  }
}

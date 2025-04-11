//
//  APIClient.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

public protocol APIService: URLRequestConvertible {
  var path: String { get }
  var method: HTTPMethod { get }
  var parameters: Parameters? { get }
  var queryParameters: Parameters? { get }
  var headers: HTTPHeaders? { get }
}

public extension APIService {
  var parameters: Parameters? { return nil }
  var queryParameters: Parameters? { return nil }
  var headers: HTTPHeaders? { return nil }

  func asURLRequest() throws -> URLRequest {
    guard let baseURL = URL(string: APIConfig.baseURL) else {
      throw NetworkError.invalidURL
    }

    let url = baseURL.appendingPathComponent(path)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue

    if let headers = headers {
      headers.forEach { header in
        urlRequest.headers.add(header)
      }
    }

    if let queryParameters = queryParameters {
      urlRequest = try URLEncoding.default.encode(urlRequest, with: queryParameters)
    }

    if let parameters = parameters, method != .get {
      urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
    }

    return urlRequest
  }
}

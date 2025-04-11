//
//  APIClient.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

public final class APIClient: @unchecked Sendable {
  private let session: Session

  public init() {
    let interceptor = APIRequestInterceptor()
    let logger = NetworkLogger()

    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60

    session = Session(
      configuration: configuration,
      interceptor: interceptor,
      eventMonitors: [logger]
    )
  }

  public func request<T: Decodable & Sendable>(_ service: some APIService) async throws(NetworkError) -> T {
    do {
      let response = try await session
        .request(service)
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self)
        .value
      return response
    } catch let afError as AFError {
      if let statusCode = afError.responseCode {
        switch statusCode {
        case 401:
          throw NetworkError.authenticationRequired
        case 403:
          throw NetworkError.forbidden
        case 404:
          throw NetworkError.notFound
        case 500...599:
          throw NetworkError.serverError
        default:
          throw NetworkError.afError(afError)
        }
      } else {
        throw NetworkError.afError(afError)
      }
    } catch let decodingError as DecodingError {
      throw NetworkError.decodingError(decodingError)
    } catch {
      throw NetworkError.unknown(error)
    }
  }

  public func requestWithPagination<T: Decodable & Sendable>(
    _ service: some APIService
  ) async throws(NetworkError)  -> (data: T, hasNextPage: Bool, nextPageURL: URL?) {
    do {
      let dataRequest = session
        .request(service)
        .validate(statusCode: 200..<300)

      let dataResponse: AFDataResponse<Data> = await dataRequest.serializingData().response

      var hasNextPage = false
      var nextPageURL: URL? = nil

      if let linkHeader = dataResponse.response?.allHeaderFields["Link"] as? String {
        let links = parseLinkHeader(linkHeader)
        hasNextPage = links["next"] != nil
        if let nextURLString = links["next"] {
          nextPageURL = URL(string: nextURLString)
        }
      }

      let value: T = try await dataRequest.serializingDecodable(T.self).value

      return (data: value, hasNextPage: hasNextPage, nextPageURL: nextPageURL)
    } catch let afError as AFError {
      throw NetworkError.afError(afError)
    } catch let decodingError as DecodingError {
      throw NetworkError.decodingError(decodingError)
    } catch {
      throw NetworkError.unknown(error)
    }
  }

  /// Helper method to parse GitHub's Link header for pagination.
  private func parseLinkHeader(_ header: String) -> [String: String] {
    var links: [String: String] = [:]

    let components = header.components(separatedBy: ",")
    for component in components {
      let subComponents = component.components(separatedBy: ";")
      guard subComponents.count >= 2 else { continue }

      var urlString = subComponents[0].trimmingCharacters(in: CharacterSet.whitespaces)
      if urlString.hasPrefix("<") && urlString.hasSuffix(">") {
        urlString = String(urlString.dropFirst().dropLast())
      }

      let relComponent = subComponents[1].trimmingCharacters(in: CharacterSet.whitespaces)
      if relComponent.hasPrefix("rel=\"") && relComponent.hasSuffix("\"") {
        let rel = relComponent.replacingOccurrences(of: "rel=\"", with: "")
          .replacingOccurrences(of: "\"", with: "")
        links[rel] = urlString
      }
    }

    return links
  }
}

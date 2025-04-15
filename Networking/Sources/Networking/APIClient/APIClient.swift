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
  ) async throws(NetworkError) -> (data: T, paginationInfo: PaginationInfo) {
    do {
      let dataRequest = session
        .request(service)
        .validate(statusCode: 200..<300)

      let dataResponse: AFDataResponse<Data> = await dataRequest.serializingData().response

      var canLoadMore = false
      var nextPageURL: URL? = nil

      if let linkHeader = dataResponse.response?.allHeaderFields["Link"] as? String {
        let links = parseLinkHeader(linkHeader)
        canLoadMore = links["next"] != nil
        if let nextURLString = links["next"] {
          nextPageURL = URL(string: nextURLString)
        }
      }

      let value: T = try await dataRequest.serializingDecodable(T.self).value

      return (data: value, paginationInfo: PaginationInfo(canLoadMore: canLoadMore, nextPageURL: nextPageURL))

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

    let linkComponents = header.components(separatedBy: ",")

    for linkComponent in linkComponents {
      let components = linkComponent.components(separatedBy: ";")
      guard components.count >= 2 else { continue }

      let urlPart = components[0].trimmingCharacters(in: .whitespaces)
      let trimmedURLString = urlPart.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))

      guard let urlComponents = URLComponents(string: trimmedURLString), let _ = urlComponents.url else {
        continue
      }

      let relPart = components[1].trimmingCharacters(in: .whitespaces)
      let prefix = "rel=\""
      let suffix = "\""
      guard relPart.hasPrefix(prefix), relPart.hasSuffix(suffix) else { continue }
      let rel = String(relPart.dropFirst(prefix.count).dropLast(suffix.count))

      links[rel] = trimmedURLString
    }

    return links
  }
}

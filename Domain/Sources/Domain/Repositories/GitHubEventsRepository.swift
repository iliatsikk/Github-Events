//
//  GitHubEventsRepository.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Networking

public protocol GitHubEventsRepositoring {
  func listPublicEvents(
    paginationState: PaginationState
  ) async throws(NetworkError) -> (data: [EventItem], paginationInfo: PaginationInfo)
}

public final class GitHubEventsRepository: GitHubEventsRepositoring {
  private let apiClient: APIClient

  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func listPublicEvents(
    paginationState: PaginationState
  ) async throws(NetworkError) -> (data: [EventItem], paginationInfo: PaginationInfo) {

    // Determine the URL to request
    let urlToRequest: URL
    if let nextURL = await paginationState.nextPageURL {
      urlToRequest = nextURL
    } else {
      guard let initialURL = URL(string: "https://api.github.com/events?page=1&per_page=\(PaginationState.perPage)") else {
        throw NetworkError.invalidURL
      }
      urlToRequest = initialURL
    }

    let service = GitHubEventsService.listPublicEvents(directURL: urlToRequest)

    let result: (data: [EventItem], paginationInfo: PaginationInfo) = try await apiClient.requestWithPagination(service)

    return result
  }
}

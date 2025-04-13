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
  func listLatestPublicEvents(perPage: Int) async throws(NetworkError) -> [EventItem]
}

public final class GitHubEventsRepository: GitHubEventsRepositoring {
  private let apiClient: APIClient

  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func listPublicEvents(
    paginationState: PaginationState
  ) async throws(NetworkError) -> (data: [EventItem], paginationInfo: PaginationInfo) {

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

  public func listLatestPublicEvents(perPage: Int) async throws(NetworkError) -> [EventItem] {
    try await apiClient.request(GitHubEventsService.listLatestPublicEvents(perPage: perPage))
  }
}

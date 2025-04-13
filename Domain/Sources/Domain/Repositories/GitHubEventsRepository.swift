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
    paginationState: PaginationState,
    filter: Set<EventTypeFilter>
  ) async throws(NetworkError) -> (data: [EventItem], paginationInfo: PaginationInfo)
  func listLatestPublicEvents(perPage: Int, filter: Set<EventTypeFilter>) async throws(NetworkError) -> [EventItem]
}

public final class GitHubEventsRepository: GitHubEventsRepositoring {
  private let apiClient: APIClient

  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func listPublicEvents(
    paginationState: PaginationState,
    filter: Set<EventTypeFilter>
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

    let allowedTypeStrings = Set(filter.map { $0.rawValue })

    let filteredData = result.data.filter { event in
      allowedTypeStrings.contains(event.type)
    }

    return (filteredData, result.paginationInfo)
  }

  public func listLatestPublicEvents(perPage: Int, filter: Set<EventTypeFilter>) async throws(NetworkError) -> [EventItem] {
    let data: [EventItem] = try await apiClient.request(GitHubEventsService.listLatestPublicEvents(perPage: perPage))
    let allowedTypeStrings = Set(filter.map { $0.rawValue })

    let filteredItems = data.filter { event in
      allowedTypeStrings.contains(event.type)
    }

    return filteredItems
  }
}

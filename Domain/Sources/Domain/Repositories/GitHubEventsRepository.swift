//
//  GitHubEventsRepository.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Networking

public protocol GitHubEventsRepositoring {
  func listPublicEvents(perPage: Int?, page: Int?) async throws(NetworkError) -> [EventItem]
}

public final class GitHubEventsRepository: GitHubEventsRepositoring {
  private let apiClient: APIClient

  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  public func listPublicEvents(perPage: Int?, page: Int?) async throws(NetworkError) -> [EventItem] {
    try await apiClient.request(GitHubEventsService.listPublicEvents(perPage: perPage, page: page))
  }
}

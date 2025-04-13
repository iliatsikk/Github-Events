//
//  GitHubEventsService.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

public enum GitHubEventsService {
  case listPublicEvents(directURL: URL?)
  case listLatestPublicEvents(perPage: Int)
}

extension GitHubEventsService: APIService {
  public var path: String {
    switch self {
    case .listPublicEvents: "/events"
    case .listLatestPublicEvents: "/events"
    }
  }

  public var method: HTTPMethod {
    return .get
  }

  public var directPathURL: URL? {
    switch self {
    case .listPublicEvents(let url): url
    case .listLatestPublicEvents: nil
    }
  }

  public var queryParameters: Parameters? {
    switch self {
    case .listPublicEvents: nil
    case .listLatestPublicEvents(let perPage): ["page": 1, "per_page": perPage]
    }
  }
}

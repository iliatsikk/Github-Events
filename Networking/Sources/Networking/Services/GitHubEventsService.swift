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
}

extension GitHubEventsService: APIService {
  public var path: String {
    switch self {
    case .listPublicEvents: "/events"
    }
  }

  public var method: HTTPMethod {
    return .get
  }

  public var directPathURL: URL? {
    switch self {
    case .listPublicEvents(let url): url
    }
  }
}

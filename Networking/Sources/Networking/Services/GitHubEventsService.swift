//
//  GitHubEventsService.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation
import Alamofire

public enum GitHubEventsService {
  case listPublicEvents(perPage: Int?, page: Int?)
}

extension GitHubEventsService: APIService {
  public var path: String {
    switch self {
    case .listPublicEvents:
      return "/events"
    }
  }

  public var method: HTTPMethod {
    return .get
  }

  public var queryParameters: Parameters? {
    switch self {
    case .listPublicEvents(let perPage, let page):
      var params: [String: Sendable] = [:]

      if let perPage {
        params["per_page"] = perPage
      }

      if let page {
        params["page"] = page
      }
      return params.isEmpty ? .none : params
    }
  }
}

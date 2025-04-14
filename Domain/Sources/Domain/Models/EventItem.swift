//
//  EventItem.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation

public struct EventItem: Codable, Equatable, Sendable, Hashable {
  public let id: String
  public let type: String
  public let actor: Actor
  public let repo: Repo
  public let createdAt: String

  public var actorImageURL: URL? {
    guard let string = actor.avatarUrl else { return nil }
    return URL(string: string)
  }

  public var formatedDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    guard let date = dateFormatter.date(from: createdAt) else { return "" }

    dateFormatter.dateFormat = "dd MMM yyyy - HH:mm"
    return dateFormatter.string(from: date)
  }

  enum CodingKeys: String, CodingKey {
    case id, type, actor, repo
    case createdAt = "created_at"
  }

  public struct Actor: Codable, Equatable, Sendable, Hashable {
    public let id: Int
    public let login: String
    public let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
      case id, login
      case avatarUrl = "avatar_url"
    }
  }

  public struct Repo: Codable, Equatable, Sendable, Hashable {
    public let id: Int
    public let name: String
  }
}

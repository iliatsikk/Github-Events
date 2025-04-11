//
//  EventItem.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 11.04.25.
//

import Foundation

public struct EventItem: Codable {
  public let id: String
  public let type: String
  public let actor: Actor
  public let repo: Repo
  public let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id, type, actor, repo
    case createdAt = "created_at"
  }

  public struct Actor: Codable {
    public let id: Int
    public let login: String
    public let avatarUrl: URL?

    public init(id: Int, login: String, avatarUrl: URL?) {
      self.id = id
      self.login = login
      self.avatarUrl = avatarUrl
    }

    enum CodingKeys: String, CodingKey {
      case id, login
      case avatarUrl = "avatar_url"
    }
  }

  public struct Repo: Codable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
      self.id = id
      self.name = name
    }
  }
}

extension EventItem: Equatable, Sendable, Hashable {}
extension EventItem.Repo: Equatable, Sendable, Hashable {}
extension EventItem.Actor: Equatable, Sendable, Hashable {}

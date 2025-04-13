//
//  ProductListingItemContentConfiguration.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation

public extension ProductListingItemContentView {
  struct Configuration: Hashable, Equatable, Sendable {
    public let id: String
    public let imageURL: URL?
    public let title: String
    public let description: String?

    public init(id: String, imageURL: URL?, title: String, description: String?) {
      self.id = id
      self.imageURL = imageURL
      self.title = title
      self.description = description
    }
  }
}

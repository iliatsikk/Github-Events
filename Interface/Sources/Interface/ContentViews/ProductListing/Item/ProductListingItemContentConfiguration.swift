//
//  ProductListingItemContentConfiguration.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import SwiftUI

public extension ProductListingItemContentView {
  struct Configuration: Hashable, Equatable, Sendable {
    public let id: String
    public let imageURL: URL?
    public let title: String
    public let description: String?
    public let backgroundColor: Color

    public init(
      id: String, imageURL: URL?, title: String, description: String?, index: Int
    ) {
      self.id = id
      self.imageURL = imageURL
      self.title = title
      self.description = description
      self.backgroundColor = Configuration.getColor(by: index)
    }

    private static func getColor(by index: Int) -> Color {
      if index % 4 == 0 {
        Color.System.pink
      } else if index % 4 == 1 {
        Color.System.purple
      } else if index  % 4 == 2 {
        Color.System.violet
      } else {
        Color.System.green
      }
    }
  }
}

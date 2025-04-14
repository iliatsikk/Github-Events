//
//  DetailsRepositoryContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Domain
import SwiftUI

public struct DetailsRepositoryContentView: View {
  public let repository: EventItem.Repo

  public init(repository: EventItem.Repo) {
    self.repository = repository
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 8.0.scaledWidth) {
      Text("Repository")
        .font(.callout)
        .foregroundColor(.secondary)

      Text(repository.name)
        .font(.headline)

      Text("Repo ID: \(repository.id)")
        .font(.caption)
    }
    .padding(.leading, 4.0.scaledWidth)
  }
}

//
//  DetailsEventIDContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import SwiftUI

public struct DetailsEventIDContentView: View {
  private let id: String

  public init(id: String) {
    self.id = id
  }

  public var body: some View {
    HStack(spacing: 8.0.scaledWidth) {
      Image(systemName: "number.circle")
        .foregroundColor(.secondary)

      Text("Event ID:")
        .font(.subheadline).foregroundColor(.secondary)

      Text(id)
        .font(.subheadline.monospaced())
        .foregroundColor(.secondary)
        .lineLimit(1)
        .truncationMode(.middle)

      Spacer()
    }
    .padding(.leading, 4.0.scaledWidth)
  }
}

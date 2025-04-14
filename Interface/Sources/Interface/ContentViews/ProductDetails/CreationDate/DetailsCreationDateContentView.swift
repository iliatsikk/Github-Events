//
//  DetailsCreationDateContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import SwiftUI

public struct DetailsCreationDateContentView: View {
  private let dateString: String

  public init(dateString: String) {
    self.dateString = dateString
  }

  public var body: some View {
    HStack(spacing: 8.0.scaledWidth) {
      Image(systemName: "clock")
        .foregroundColor(.secondary)

      Text(dateString)
        .font(.subheadline)
        .foregroundColor(.secondary)
      Spacer()
    }
    .padding(.leading, 4.0.scaledWidth)
  }
}

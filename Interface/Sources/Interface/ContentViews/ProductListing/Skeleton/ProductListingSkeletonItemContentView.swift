//
//  ProductListingSkeletonItemContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import SwiftUI

public struct ProductListingSkeletonItemContentView: View {
  public init() {}

  public var body: some View {
    VStack(alignment: .leading, spacing: 8.0.scaledWidth) {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(uiColor: .tertiarySystemBackground))
        .frame(height: 100.0.scaledWidth)

      RoundedRectangle(cornerRadius: 8)
        .fill(Color(uiColor: .tertiarySystemBackground))
        .frame(height: 14.0.scaledWidth)
        .padding(.top, 4.0.scaledWidth)

      RoundedRectangle(cornerRadius: 8)
        .fill(Color(uiColor: .tertiarySystemBackground))
        .frame(width: 100.0.scaledWidth, height: 12.0.scaledWidth)
        .padding(.top, 2.0.scaledWidth)

      Spacer()
    }
    .padding(4.0.scaledWidth)
    .redacted(reason: .placeholder)
    .opacity(0.9)
  }
}

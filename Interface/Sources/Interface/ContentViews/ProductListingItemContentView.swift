//
//  ProductListingItemContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import SwiftUI
import Kingfisher
import DesignSystem

public struct ProductListingItemContentView: View {
  let configuration: Configuration

  public init(configuration: Configuration) {
    self.configuration = configuration
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 4.0.scaledWidth) {
      KFImage(configuration.imageURL)
        .placeholder({ progress in
          Image(ImageResource.Icons.placeholder)
            .resizable()
            .clipShape(.rect(cornerRadius: 4))
        })
        .resizable()
        .cancelOnDisappear(true)
        .scaledToFill()
        .frame(width: 40.0.scaledWidth, height: 40.0.scaledWidth)
        .padding(.bottom, 8.0.scaledWidth)
        .clipShape(.circle)
        .clipped()

      Text(configuration.title)
        .font(.headline)
        .lineLimit(2)

      if let description = configuration.description, !description.isEmpty {
        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }

      Spacer()
    }
    .frame(
      minWidth: .zero,
      maxWidth: .infinity,
      minHeight: .zero,
      maxHeight: .infinity,
      alignment: .leading
    )
    .padding(8.0.scaledWidth)
    .background(configuration.backgroundColor.opacity(0.9))
    .cornerRadius(10)
  }
}

#Preview {
  ProductListingItemContentView(
    configuration: .init(
      id: "uuid",
      imageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPQzg2-modiBeSBIckt_NcpipPPGQfZA_dbQ&s"),
      title: "Something title 1 Something title 1 Something title 1",
      description: "desc",
      index: .zero
    )
  )
  .frame(
    width: Constants.Screen.width / 2,
    height: 160.0.scaledWidth)
}

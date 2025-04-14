//
//  DetailsActorContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import SwiftUI
import Domain
import Kingfisher

public struct DetailsActorContentView: View {
  private let data: EventItem.Actor

  public init(data: EventItem.Actor) {
    self.data = data
  }

  public var body: some View {
    HStack(spacing: 8.0.scaledWidth) {
      if let urlString = data.avatarUrl, let url = URL(string: urlString) {
        KFImage(url)
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
      }

      VStack(alignment: .leading) {
        Text(data.login)
          .font(.headline)
          .foregroundColor(.System.text)

        Text("Actor ID: \(data.id)")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }
}

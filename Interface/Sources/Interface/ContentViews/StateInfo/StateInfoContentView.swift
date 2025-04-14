//
//  StateInfoContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import SwiftUI
import DesignSystem

public enum StateInfoType: Hashable, Identifiable, Sendable {
  case empty
  case error(title: String, description: String)

  public var id: String {
    switch self {
    case .empty: "state_empty"
    case .error: "state_error"
    }
  }

  var title: String {
    switch self {
    case .empty: "No Events"
    case .error(let title, _): title
    }
  }

  var description: String {
    switch self {
    case .empty: "There are no events to show."
    case .error(_, let description): description
    }
  }

  var systemImageName: String {
    switch self {
    case .empty: "tray.fill"
    case .error: "exclamationmark.triangle.fill"
    }
  }
}

public struct StateInfoContentView: View {
  private let stateType: StateInfoType

  public init(stateType: StateInfoType) {
    self.stateType = stateType
  }

  public var body: some View {
    VStack(spacing: 16.0.scaledWidth) {
      Image(systemName: stateType.systemImageName)
        .resizable()
        .scaledToFit()
        .frame(width: 60.0.scaledWidth, height: 60.0.scaledWidth)
        .foregroundColor(Color(UIColor.systemGray))

      VStack(spacing: 4) {
        Text(stateType.title)
          .font(.headline)
          .foregroundColor(Color(UIColor.label))

        Text(stateType.description)
          .font(.subheadline)
          .foregroundColor(Color(UIColor.secondaryLabel))
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
    }
    .padding(32.0.scaledWidth)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

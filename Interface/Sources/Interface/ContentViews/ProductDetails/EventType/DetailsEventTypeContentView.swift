//
//  DetailsEventTypeContentView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Domain
import SwiftUI

public struct DetailsEventTypeContentView: View {
  private let eventType: EventTypeFilter?

  public init(eventType: EventTypeFilter?) {
    self.eventType = eventType
  }

  public var body: some View {
    HStack(spacing: 8.0.scaledWidth) {
      Image(systemName: getSystemIcon(for: eventType))
        .font(.title2)
        .foregroundColor(.System.text)

      Text(eventType?.rawValue ?? "")
        .font(.title2.bold())

      Spacer()
    }
  }

  // MARK: - Private Implementations

  private func getSystemIcon(for eventType: EventTypeFilter?) -> String {
    switch eventType {
    case .push: "arrow.up.circle.fill"
    case .issues: "exclamationmark.bubble.circle.fill"
    case .public: "plus.circle.fill"
    case .pullRequest: "arrow.triangle.pull"
    case .watch, nil: "star.circle.fill"
    }
  }
}

//
//  ProductDetailsViewModel.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import SwiftUI
import DesignSystem
import Domain
import Kingfisher

enum ProductDetailItem: Hashable, CaseIterable {
  case eventType
  case actor
  case repository
  case creationDate
  case eventId
}

@MainActor
final class ProductDetailsViewModel: NSObject, ProductDetailsViewModelInputs, ProductDetailsViewModelOutputs {
  typealias Actions = ProductDetailsViewController.ViewActions
  typealias DataSourceItem = ProductDetailsViewController.DataSourceItem

  let stream: AsyncStream<Actions?>
  let eventItem: EventItem

  private var actionContinuation: AsyncStream<Actions?>.Continuation?

  // MARK: - Initialization

  init(eventItem: EventItem) {
    self.eventItem = eventItem
    var capturedContinuation: AsyncStream<Actions?>.Continuation?
    stream = AsyncStream { capturedContinuation = $0 }
    actionContinuation = capturedContinuation

    super.init()
  }

  deinit {
    print("Deinit ProductDetailsViewModel")
    actionContinuation?.finish()
    actionContinuation = nil
  }

  // MARK: - Inputs

  func viewDidLoad() {
    updateDataSource()
  }

  // MARK: - Data Processing

  private func updateDataSource() {
    let details: [ProductDetailItem] = ProductDetailItem.allCases

    send(action: .displayDetails(details))
  }

  // MARK: - Private Implementations

  private func send(action: Actions?) {
    actionContinuation?.yield(action)
  }
}

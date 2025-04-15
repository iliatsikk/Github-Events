//
//  ProductListingViewModelType.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation
import UIKit
import Domain

@MainActor
extension ProductListingViewController {
  enum ViewActions: Sendable {
    case updatePaginationState(isLoading: Bool)
    case setContent(items: [DataSourceItem], section: Section, needsReset: Bool = false)
  }
}

@MainActor
protocol ProductListingViewModelInputs {
  func viewDidLoad()
  func checkScrollPositionAndTriggerLoadIfNeeded(_ scrollView: UIScrollView) async
  func applyFilter(_ filters: Set<EventTypeFilter>)
}

@MainActor
protocol ProductListingViewModelOutputs {
  var stream: AsyncStream<ProductListingViewController.ViewActions?> { get }
  var currentFilters: Set<EventTypeFilter> { get }
  var eventItems: [EventItem] { get }
}

@MainActor
protocol ProductListingViewModelType {
  /// inputs are used to give data to view model
  var inputs: ProductListingViewModelInputs { get }
  /// getters are used to recieve data from view model
  var outputs: ProductListingViewModelOutputs { get }
}

@MainActor
extension ProductListingViewModel: ProductListingViewModelType {
  var inputs: ProductListingViewModelInputs { self }
  var outputs: ProductListingViewModelOutputs { self }
}

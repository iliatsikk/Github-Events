//
//  ProductListingViewModelType.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation

@MainActor
extension ProductListingViewController {
  enum ViewActions: Sendable {
    case testForBinding
  }
}

@MainActor
protocol ProductListingViewModelInputs {
  func viewDidLoad()
}

@MainActor
protocol ProductListingViewModelOutputs {
  var stream: AsyncStream<ProductListingViewController.ViewActions?> { get }
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

//
//  ProductDetailsViewModelType.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import Domain

@MainActor
extension ProductDetailsViewController {
  enum ViewActions: Sendable {
    case displayDetails([ProductDetailItem])
  }
}

@MainActor
protocol ProductDetailsViewModelInputs {
  func viewDidLoad()
}

@MainActor
protocol ProductDetailsViewModelOutputs {
  var stream: AsyncStream<ProductDetailsViewController.ViewActions?> { get }
  var eventItem: EventItem { get }
}

@MainActor
protocol ProductDetailsViewModelType {
  var inputs: ProductDetailsViewModelInputs { get }
  var outputs: ProductDetailsViewModelOutputs { get }
}

@MainActor
extension ProductDetailsViewModel: ProductDetailsViewModelType {
  var inputs: ProductDetailsViewModelInputs { self }
  var outputs: ProductDetailsViewModelOutputs { self }
}

//
//  ProductListingViewModel.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation
import Networking
import Domain
import UIKit

enum Section: Hashable {
  case listing
}

struct ProductItem: Hashable, Identifiable, Equatable {
  let id = UUID()
  let imageName: String
  let title: String
  let description: String?

  static let placeholderImageName = "photo.fill"

  static func testData() -> [ProductItem] {
    return [
      ProductItem(imageName: "swift", title: "Swift Book", description: "Learn the Swift language"),
      ProductItem(imageName: "keyboard", title: "Magic Keyboard", description: "With Touch ID"),
      ProductItem(imageName: "macpro.gen3", title: "Mac Pro", description: "Powerhouse desktop"),
      ProductItem(imageName: "display", title: "Studio Display", description: "5K Retina"),
      ProductItem(imageName: "iphone", title: "iPhone 15 Pro", description: "Titanium frame"),
      ProductItem(imageName: "ipad", title: "iPad Air", description: "M2 Chip"),
      ProductItem(imageName: "airpodsmax", title: "AirPods Max", description: "High-fidelity audio"),
      ProductItem(imageName: "applewatch.ultra", title: "Apple Watch Ultra 2", description: "Adventure awaits")
    ]
  }
}

@MainActor
final class ProductListingViewModel: NSObject, ProductListingViewModelInputs, ProductListingViewModelOutputs {
  typealias Actions = ProductListingViewController.ViewActions

  let stream: AsyncStream<Actions?>

  private var actionContinuation: AsyncStream<ProductListingViewController.ViewActions?>.Continuation?

  override init() {
    var capturedContinuation: AsyncStream<ProductListingViewController.ViewActions?>.Continuation?
    stream = AsyncStream { continuation in
      capturedContinuation = continuation
    }

    actionContinuation = capturedContinuation
  }

  deinit {
    actionContinuation?.finish()
    actionContinuation = nil

    print("Deinit ProductListingViewModel")
  }

  func viewDidLoad() {
    getData()
  }

  // MARK: - Repository

  private func getData() {
    let apiClient = APIClient()
    let repository: GitHubEventsRepositoring = GitHubEventsRepository(apiClient: apiClient)
  
    Task { [weak self] in
      do {
        let data = try await repository.listPublicEvents(perPage: 10, page: 1)

        try await Task.sleep(nanoseconds: 2_000_000_000)
        self?.send(action: .testForBinding)
        print("*** \(data)")
      } catch {
        print("*** \(error)")
      }
    }
  }

  // MARK: - Private Implementations

  private func send(action: ProductListingViewController.ViewActions?) {
    actionContinuation?.yield(action)
  }
}

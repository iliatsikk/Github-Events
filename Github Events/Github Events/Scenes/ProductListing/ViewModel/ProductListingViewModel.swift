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
import Interface

enum Section: Hashable {
  case listing
}

extension EventItem {
  func toConfigurationItem() -> ProductListingItemContentView.Configuration {
    return .init(
      id: id,
      imageURL: actorImageURL,
      title: repo.name,
      description: type
    )
  }
}

@MainActor
final class ProductListingViewModel: NSObject, ProductListingViewModelInputs, ProductListingViewModelOutputs {
  typealias Actions = ProductListingViewController.ViewActions
  typealias DataSourceItem = ProductListingViewController.DataSourceItem

  let stream: AsyncStream<Actions?>

  private var actionContinuation: AsyncStream<Actions?>.Continuation?

  override init() {
    var capturedContinuation: AsyncStream<Actions?>.Continuation?
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

        let configurationItems = data.map({ $0.toConfigurationItem() })

        self?.send(action: .applyItems(configurationItems))
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

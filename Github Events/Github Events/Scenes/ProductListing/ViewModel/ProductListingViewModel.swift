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
  func toConfigurationItem(index: Int) -> ProductListingItemContentView.Configuration {
    return .init(
      id: id,
      imageURL: actorImageURL,
      title: repo.name,
      description: type,
      index: index
    )
  }
}

@MainActor
final class ProductListingViewModel: NSObject, ProductListingViewModelInputs, ProductListingViewModelOutputs {
  typealias Actions = ProductListingViewController.ViewActions
  typealias DataSourceItem = ProductListingViewController.DataSourceItem

  let stream: AsyncStream<Actions?>

  private var actionContinuation: AsyncStream<Actions?>.Continuation?

  private var paginationState: PaginationState = .init()

  private var scrollCheckTask: Task<Void, Never>? = nil

  override init() {
    var capturedContinuation: AsyncStream<Actions?>.Continuation?
    stream = AsyncStream { continuation in
      capturedContinuation = continuation
    }

    actionContinuation = capturedContinuation
  }

  deinit {
    actionContinuation?.finish()
    scrollCheckTask?.cancel()
    scrollCheckTask = nil
    actionContinuation = nil

    print("Deinit ProductListingViewModel")
  }

  // MARK: - Inputs

  func viewDidLoad() {
    Task { [weak self] in
      await self?.getData()
    }
  }

  func checkScrollPositionAndTriggerLoadIfNeeded(_ scrollView: UIScrollView) async {
    guard await paginationState.canStartLoading() else { return }

    let contentHeight = scrollView.contentSize.height
    let frameHeight = scrollView.bounds.height
    guard contentHeight > frameHeight else { return }

    let offsetY = scrollView.contentOffset.y
    let distanceToBottom = contentHeight - offsetY - frameHeight
    let threshold = frameHeight * 1.0

    if distanceToBottom <= threshold {
      await didReachToBottom()
    }
  }

  // MARK: - Repository

  private func getData() async {
    let apiClient = APIClient()
    let repository: GitHubEventsRepositoring = GitHubEventsRepository(apiClient: apiClient)

    var fetchedItems: [EventItem]? = nil
    var fetchedPaginationInfo: PaginationInfo? = nil
    var fetchError: Error? = nil

    do {
      let dataResult = try await repository.listPublicEvents(paginationState: paginationState)

      fetchedItems = dataResult.data
      fetchedPaginationInfo = dataResult.paginationInfo

      try Task.checkCancellation()

      let configurationItems = fetchedItems!.enumerated().map { index, element in
        element.toConfigurationItem(index: index)
      }

      try Task.checkCancellation()

      send(action: .applyItems(configurationItems))
    } catch {
      fetchError = error
    }

    let success = (fetchError == nil && fetchedPaginationInfo != nil)
    let canLoadMore = fetchedPaginationInfo?.canLoadMore ?? false
    let nextURL = fetchedPaginationInfo?.nextPageURL

    await paginationState.finishedLoading(success: success, hasMoreData: canLoadMore, nextURL: nextURL)
  }

  // MARK: - Private Implementations

  private func send(action: ProductListingViewController.ViewActions?) {
    actionContinuation?.yield(action)
  }

  private func didReachToBottom() async {
    let didStartLoading = await paginationState.startLoadingIfNeeded()

    guard didStartLoading else {
      return
    }

    await getData()
  }
}

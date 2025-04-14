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

extension ProductListingViewModel {
  enum ListingItem: Hashable, Identifiable {
    case item(ProductListingItemContentView.Configuration)
    case skeleton(id: UUID = UUID())
    case stateInfo(StateInfoType)

    var id: AnyHashable {
      switch self {
      case .item(let config): config.id
      case .skeleton(let id): id
      case .stateInfo(let type): type.id
      }
    }
  }
}

@MainActor
final class ProductListingViewModel: NSObject, ProductListingViewModelInputs, ProductListingViewModelOutputs {
  typealias Actions = ProductListingViewController.ViewActions
  typealias DataSourceItem = ListingItem

  let stream: AsyncStream<Actions?>
  var currentFilters: Set<EventTypeFilter> = Set(EventTypeFilter.allCases)
  var eventItems: [EventItem] = []

  private var actionContinuation: AsyncStream<Actions?>.Continuation?
  private let paginationState: PaginationState = .init()

  private var refreshTimerTask: Task<Void, Never>? = nil
  private let refreshInterval: TimeInterval = 10.0

  private let apiClient = APIClient()
  private let repository: GitHubEventsRepositoring

  override init() {
    var capturedContinuation: AsyncStream<Actions?>.Continuation?
    stream = AsyncStream { continuation in
      capturedContinuation = continuation
    }

    actionContinuation = capturedContinuation
    repository = GitHubEventsRepository(apiClient: apiClient)

    super.init()
    startRefreshTimer()
  }

  deinit {
    print("Deinit ProductListingViewModel")
    refreshTimerTask?.cancel()
    actionContinuation?.finish()
    actionContinuation = nil
  }

  // MARK: - Inputs

  func viewDidLoad() {
    Task { [weak self] in
      self?.send(action: .showSkeletons(count: PaginationState.perPage))

      await self?.fetchAndApplyInitialData()
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
      await triggerLoadMoreData()
    }
  }

  func applyFilter(_ filters: Set<EventTypeFilter>) {
    self.currentFilters = filters

    Task { [weak self] in
      self?.send(action: .showSkeletons(count: PaginationState.perPage))

      await self?.fetchAndApplyInitialData()
    }
  }

  // MARK: - Data Fetching / Actions

  private func fetchAndApplyInitialData() async {
    await paginationState.reset()
    await paginationState.setIsLoading(true)

    await fetchPaginatedData(isInitialLoad: true)
  }

  private func triggerLoadMoreData() async {
    let didStartLoading = await paginationState.startLoadingIfNeeded()

    guard didStartLoading else { return }

    send(action: .updatePaginationState(isLoading: true))

    await fetchPaginatedData(isInitialLoad: false)
  }

  private func fetchPaginatedData(isInitialLoad: Bool) async {
    var fetchedItems: [EventItem]? = nil
    var fetchedPaginationInfo: PaginationInfo? = nil
    var fetchError: Error? = nil

    do {
      let dataResult = try await repository.listPublicEvents(paginationState: paginationState, filter: currentFilters)
      fetchedItems = dataResult.data
      fetchedPaginationInfo = dataResult.paginationInfo
      try Task.checkCancellation()

      let configurationItems = fetchedItems!.enumerated().map { index, element in
        element.toConfigurationItem(index: index)
      }
      let listingItems = configurationItems.map { ListingItem.item($0) }

      try Task.checkCancellation()

      self.eventItems = dataResult.data

      if isInitialLoad && listingItems.isEmpty {
        send(action: .showEmptyState)
      } else {
        send(action: .applyItems(listingItems))
      }
    } catch {
      fetchError = error

      if isInitialLoad {
        let errorTitle = "Error Occurred"
        let errorDescription = "Failed to load events. Please try again."
        send(action: .showErrorState(title: errorTitle, description: errorDescription))
      }
    }

    let success = (fetchError == nil && fetchedPaginationInfo != nil)
    let canLoadMore = fetchedPaginationInfo?.canLoadMore ?? false
    let nextURL = fetchedPaginationInfo?.nextPageURL

    await paginationState.finishedLoading(success: success, hasMoreData: canLoadMore, nextURL: nextURL)

    send(action: .updatePaginationState(isLoading: false))
  }

  private func fetchLatestEvents() async {
    do {
      let perPage = PaginationState.perPage
      let latestItems = try await repository.listLatestPublicEvents(perPage: perPage, filter: currentFilters)
      try Task.checkCancellation()
      if !latestItems.isEmpty {
        let configurationItems = latestItems.enumerated().map { index, element in
          element.toConfigurationItem(index: index)
        }

        let listingItems = configurationItems.map { ListingItem.item($0) }

        eventItems.append(contentsOf: latestItems)
        send(action: .attachItems(listingItems))
      }
    } catch {
      print(error)
    }
  }

  // MARK: - Timer Management

  private func startRefreshTimer() {
    stopRefreshTimer()
    refreshTimerTask = Task { [weak self] in
      guard let self = self else { return }
      while !Task.isCancelled {
        do {
          try await Task.sleep(for: .seconds(refreshInterval))
          try Task.checkCancellation()
          await self.fetchLatestEvents()
        } catch is CancellationError {
          break
        } catch {
          try? await Task.sleep(for: .seconds(refreshInterval * 2))
        }
      }
    }
  }

  private func stopRefreshTimer() {
    refreshTimerTask?.cancel()
    refreshTimerTask = nil
  }

  // MARK: - Private Implementations

  private func send(action: ProductListingViewController.ViewActions?) {
    actionContinuation?.yield(action)
  }
}

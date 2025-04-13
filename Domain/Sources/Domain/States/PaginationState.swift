//
//  PaginationState.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation

public actor PaginationState: Sendable {
  public static var perPage: Int = 20

  public var isLoadingMore: Bool
  public var canLoadMore: Bool
  public var nextPageURL: URL?

  public var currentPage: Int

  /// checks if loading can start based on current state
  public func canStartLoading() -> Bool {
    return !isLoadingMore && canLoadMore
  }

  /// checks if loading can start and sets `isLoadingMore` to true if possible.
  /// returns true if loading was successfully started, false otherwise.
  public func startLoadingIfNeeded() -> Bool {
    guard !isLoadingMore, canLoadMore else {
      return false
    }

    self.isLoadingMore = true
    print("PaginationState: Start loading triggered (isLoadingMore = true)")
    return true
  }

  public func finishedLoading(success: Bool, hasMoreData: Bool, nextURL: URL?) {
    self.isLoadingMore = false

    if success {
      self.canLoadMore = hasMoreData
      self.nextPageURL = nextURL
      self.currentPage += 1
    } else {
      print("*** error did occurr")
    }
  }

  public func reset() {
    self.isLoadingMore = false
    self.canLoadMore = true
    self.nextPageURL = nil
    self.currentPage = 0
  }

  public func setIsLoading(_ isLoading: Bool) {
    self.isLoadingMore = isLoading
  }

  public init(
    isLoadingMore: Bool = false,
    canLoadMore: Bool = true,
    nextPageURL: URL? = nil,
    currentPage: Int = 0
  ) {
    self.isLoadingMore = isLoadingMore
    self.canLoadMore = canLoadMore
    self.nextPageURL = nextPageURL
    self.currentPage = currentPage
  }
}

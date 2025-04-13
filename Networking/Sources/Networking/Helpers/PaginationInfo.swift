//
//  PaginationInfo.swift
//  Networking
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import Foundation

public struct PaginationInfo: Sendable {
  public let canLoadMore: Bool
  public let nextPageURL: URL?
}

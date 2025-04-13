//
//  EventTypeFilter.swift
//  Domain
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation

public enum EventTypeFilter: String, CaseIterable, Sendable, Hashable {
  case pullRequest = "PullRequestEvent"
  case push = "PushEvent"
  case issues = "IssuesEvent"
  case `public` = "PublicEvent"
  case watch = "WatchEvent"
}

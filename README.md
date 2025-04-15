# GitHub Public Events iOS App

[![Swift Version](https://img.shields.io/badge/Swift-5.7%2B-orange.svg)](https://img.shields.io/badge/Swift-5.7%2B-Orange.svg)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)

## Overview

This is an iOS application built using Swift and UIKit (leveraging modern APIs like Compositional Layout and Diffable Data Source) to browse the public event feed from the official GitHub REST API. It serves as a demonstration of building a dynamic, paginated list view with filtering, background refresh, and modern concurrency patterns (`async/await`).

## Features

*   **Browse Public Events:** Displays the latest public events from GitHub.
*   **Grid Layout:** Uses `UICollectionViewCompositionalLayout` for a responsive two-column grid.
*   **Diffable Data Source:** Employs `UICollectionViewDiffableDataSource` for safe and efficient UI updates.
*   **Infinite Scrolling:** Loads more events automatically as the user scrolls towards the bottom (pagination).
*   **Filtering:** Allows users to filter the event feed by specific event types (e.g., `PushEvent`, `PullRequestEvent`, `IssuesEvent`).
*   **Event Details:** Navigate to a detail screen showing more information about a selected event.
*   **Automatic Refresh:** Periodically fetches the latest events in the background and updates the UI.
*   **"New Content" Indicator:** Displays a "New Content Added" button when new events are fetched via background refresh, allowing users to scroll to the top easily.
*   **Loading States:** Shows skeleton views while initially loading or fetching more data.
*   **Empty & Error States:** Displays informative messages if no events match the filter or if an error occurs during fetching.
*   **Modern Concurrency:** Uses Swift Concurrency (`async/await`, `Task`, `AsyncStream`) for managing asynchronous operations and data streams.
*   **MVVM Architecture:** Follows the Model-View-ViewModel pattern to separate concerns.
*   **SwiftUI Integration:** Uses `UIHostingConfiguration` to seamlessly embed SwiftUI views (`ProductListingItemContentView`, `ProductListingSkeletonItemContentView`, `StateInfoContentView`) within `UICollectionViewCell`s.

## Screenshots & Demo

| Listing Screen (Scrolling) | Filter Modal | Detail Screen 
| :------------------------: | :----------: | :-----------: 
| ![Listing screen](docs/images/grids.gif) | ![Filtering screen](docs/images/filter.gif) | ![Detail screen ](docs/images/details.png)


## Tech Stack & Architecture

*   **UI Framework:** UIKit
*   **Layout:** `UICollectionViewCompositionalLayout`
*   **Data Management (UI):** `UICollectionViewDiffableDataSource`
*   **View Embedding:** `UIHostingConfiguration` (for SwiftUI views in UIKit cells)
*   **Language:** Swift 6
*   **Concurrency:** Swift Concurrency (`async/await`, `Task`, `AsyncStream`)
*   **Architecture:** MVVM (Model-View-ViewModel)
*   **Networking:** `URLSession` (via `APIClient`), `Codable` for JSON parsing
*   **API:** GitHub REST API v3

## API Usage

This application interacts with the official GitHub REST API:

*   **List Public Events:** `GET /events` ([API Docs](https://docs.github.com/en/rest/activity/events?apiVersion=2022-11-28#list-public-events)) - Used for initial loading and pagination.
*   The app utilizes the `Link` header in the API response for pagination URLs.

## Future Enhancements

*   Add search functionality to find specific repositories or users
*   Enhance the detail view with more event-specific data based on the `type`, with custom decoding
*   Implement authentication
*   Add unit and UI tests

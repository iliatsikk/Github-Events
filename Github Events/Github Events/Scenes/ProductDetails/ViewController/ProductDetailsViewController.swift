//
//  ProductDetailsViewController.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import UIKit
import SwiftUI
import Domain
import DesignSystem
import Interface

@MainActor
class ProductDetailsViewController: UIViewController {
  typealias DataSourceItem = ProductDetailItem

  private enum Section {
    case main
  }

  private let viewModel: ProductDetailsViewModelType

  private lazy var collectionView: UICollectionView = {
    let layout = createLayout()
    return UICollectionView(frame: view.bounds, collectionViewLayout: layout)
  }()

  private var dataSource: UICollectionViewDiffableDataSource<Section, DataSourceItem>?
  private var bindingTask: Task<Void, Never>? = nil

  // MARK: - Lifecycle

  init(eventItem: EventItem) {
    self.viewModel = ProductDetailsViewModel(eventItem: eventItem)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    print("Deinit ProductDetailsViewController")
    bindingTask?.cancel()
    bindingTask = nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .System.background

    configureCollectionView()
    configureDataSource()
    bind()
    viewModel.inputs.viewDidLoad()
  }

  // MARK: - Binding

  private func bind() {
    bindingTask = Task { [weak self] in
      guard let stream = self?.viewModel.outputs.stream else { return }

      do {
        for await action in stream {
          try Task.checkCancellation()

          self?.handle(action: action)
        }
      } catch {
      }
    }
  }

  private func handle(action: ViewActions?) {
    switch action {
    case .displayDetails(let items):
      applySnapshot(items: items)
    case nil:
      print("Received nil action from ViewModel stream.")
    }
  }

  // MARK: - Configuration

  private func configureCollectionView() {
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.backgroundColor = .System.background

    view.addSubview(collectionView)
  }

  // MARK: - Layout Creation

  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0.scaledWidth)
    )

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0.scaledWidth)
    )

    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 10.0.scaledWidth, leading: 15.0.scaledWidth, bottom: 10.0.scaledWidth, trailing: 15.0.scaledWidth
    )

    section.interGroupSpacing = 8.0.scaledWidth

    return UICollectionViewCompositionalLayout(section: section)
  }

  // MARK: - Data Source

  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DataSourceItem> { [weak self] cell, indexPath, item in
      self?.getContentConfiguration(in: cell, for: item)
    }

    dataSource = UICollectionViewDiffableDataSource<Section, DataSourceItem>(collectionView: collectionView) {
      (collectionView, indexPath, item) -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }

  private func getContentConfiguration(in cell: UICollectionViewListCell, for item: DataSourceItem) {
    let eventItem = viewModel.outputs.eventItem
    let eventTypeFilter = EventTypeFilter(rawValue: eventItem.type)

    switch item {
    case .actor:
      cell.contentConfiguration = UIHostingConfiguration {
        DetailsActorContentView(data: eventItem.actor)
      }
    case .eventType:
      cell.contentConfiguration = UIHostingConfiguration {
        DetailsEventTypeContentView(eventType: eventTypeFilter)
      }
    case .repository:
      cell.contentConfiguration = UIHostingConfiguration {
        DetailsRepositoryContentView(repository: eventItem.repo)
      }
    case .creationDate:
      cell.contentConfiguration = UIHostingConfiguration {
        DetailsCreationDateContentView(dateString: eventItem.formatedDate)
      }
    case .eventId:
      cell.contentConfiguration = UIHostingConfiguration {
        DetailsEventIDContentView(id: eventItem.id)
      }
    }
  }

  // MARK: - Snapshot Update

  @MainActor
  private func applySnapshot(items: [DataSourceItem]) {
    guard let dataSource else { return }

    var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)

    dataSource.apply(snapshot, animatingDifferences: false)
  }

  @MainActor
  private func clearSnapshot() {
    guard let dataSource else { return }

    let snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

//
//  ViewController.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 10.04.25.
//

import UIKit
import Domain
import Networking
import SwiftUI
import Interface
import DesignSystem

class ProductListingViewController: UIViewController {
  typealias DataSourceItem = ProductListingItemContentView.Configuration

  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, ProductListingItemContentView.Configuration>?

  private let viewModel: ProductListingViewModelType
  private var bindingTask: Task<Void, Never>? = nil

  private var isPaginating: Bool = false

  // MARK: - Lifecycle

  init() {
    viewModel = ProductListingViewModel()
    super.init(nibName: nil, bundle: nil)
  }

  deinit {
    print("Deinit ProductListingViewController")
    bindingTask?.cancel()
    bindingTask = nil
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.System.background
    title = "Products"

    setupNavigationBar()
    bind()
    configureCollectionView()
    configureDataSource()
  }

  // MARK: - Navigation bar setup

  private func setupNavigationBar() {
    let filterButton = UIBarButtonItem(
      image: UIImage(systemName: "line.3.horizontal.decrease"),
      style: .plain,
      target: self,
      action: #selector(filterButtonTapped)
    )

    filterButton.tintColor = UIColor.System.text

    navigationItem.rightBarButtonItem = filterButton
  }

  // MARK: - Actions

  @objc private func filterButtonTapped() {
    let currentFilters = viewModel.outputs.currentFilters
    let filterModalViewController = FilterModalViewController(initialFilters: currentFilters)
    filterModalViewController.delegate = self

    let navController = UINavigationController(rootViewController: filterModalViewController)
    navController.modalPresentationStyle = .formSheet
    navController.sheetPresentationController?.detents = [.medium()]

    present(navController, animated: true, completion: nil)
  }

  // MARK: - Binding

  private func bind() {
    bindingTask = Task { [weak self] in
      guard let stream = self?.viewModel.outputs.stream else {
        return
      }

      do {
        for await action in stream {
          try Task.checkCancellation()

          self?.handle(action: action)
        }
      } catch {
      }
    }
    viewModel.inputs.viewDidLoad()
  }

  @MainActor
  private func handle(action: ViewActions?) {
    switch action {
    case .applyItems(let items):
      applyAppendOrReplaceSnapshot(items: items)
    case .attachItems(let items):
      applySnapshot(itemsToAttach: items)
    case .updatePaginationState(let isLoading):
      isPaginating = isLoading
      reloadFooterState()
    case nil:
      print("nil action received")
    }
  }

  // MARK: - Configuration

  private func configureCollectionView() {
    let layout = createLayout()
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.System.background
    view.addSubview(collectionView)

    collectionView.translatesAutoresizingMaskIntoConstraints = false

    collectionView.register(
      PaginationFooterView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: PaginationFooterView.reuseIdentifier
    )

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Layout Creation (Compositional Layout)

  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.5),
        heightDimension: .absolute(165.0.scaledWidth)
      )

      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4.0.scaledWidth, bottom: 0, trailing: 4.0.scaledWidth)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(165.0.scaledWidth)
      )

      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 8.0.scaledWidth
      section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8.0.scaledWidth, bottom: 0, trailing: 8.0.scaledWidth)

      let footerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(50.0.scaledWidth)
      )

      let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: footerSize,
        elementKind: UICollectionView.elementKindSectionFooter,
        alignment: .bottom
      )

      section.boundarySupplementaryItems = [sectionFooter]

      return section
    }

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .vertical
    layout.configuration = config

    return layout
  }

  // MARK: - Data Source (Diffable + Cell Registration + Hosting Configuration)

  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, DataSourceItem> { cell, indexPath, item in
      cell.contentConfiguration = UIHostingConfiguration {
        ProductListingItemContentView(configuration: item)
      }

      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }

    dataSource = UICollectionViewDiffableDataSource<Section, DataSourceItem>(
      collectionView: collectionView
    ) { (collectionView, indexPath, item) -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration,
        for: indexPath,
        item: item
      )
    }

    dataSource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
      guard let self = self, kind == UICollectionView.elementKindSectionFooter else { return nil }

      guard let footerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: PaginationFooterView.reuseIdentifier,
        for: indexPath
      ) as? PaginationFooterView else {
        fatalError("Failed")
      }

      if self.isPaginating {
        footerView.startAnimating()
      } else {
        footerView.stopAnimating()
      }

      return footerView
    }
  }

  // MARK: - Snapshot Update

  @MainActor
  private func applyAppendOrReplaceSnapshot(items: [DataSourceItem]) {
    guard let dataSource else { return }
    var snapshot = dataSource.snapshot()

    let isDataSourceEmpty = snapshot.numberOfItems == 0

    if isDataSourceEmpty {
      if !snapshot.sectionIdentifiers.contains(.listing) {
        snapshot.appendSections([.listing])
      }
      snapshot.appendItems(items, toSection: .listing)
      dataSource.apply(snapshot, animatingDifferences: false)
    } else {
      let existingItems = Set(snapshot.itemIdentifiers(inSection: .listing))
      let newItems = items.filter { !existingItems.contains($0) }
      if !newItems.isEmpty {
        snapshot.appendItems(newItems, toSection: .listing)
        dataSource.apply(snapshot, animatingDifferences: true)
      }
    }
  }

  @MainActor
  private func applySnapshot(itemsToAttach items: [DataSourceItem]) {
    guard let dataSource else { return }

    var snapshot = dataSource.snapshot()

    guard snapshot.sectionIdentifiers.contains(.listing) else {
      if snapshot.numberOfSections == 0 {
        snapshot.appendSections([.listing])
        snapshot.appendItems(items, toSection: .listing)
        dataSource.apply(snapshot, animatingDifferences: false)
      }
      return
    }

    let existingItems = Set(snapshot.itemIdentifiers(inSection: .listing))
    let newItems = items.filter { !existingItems.contains($0) }

    guard !newItems.isEmpty else {
      return
    }

    if let firstItem = snapshot.itemIdentifiers(inSection: .listing).first {
      snapshot.insertItems(newItems, beforeItem: firstItem)
    } else {
      snapshot.appendItems(newItems, toSection: .listing)
    }

    dataSource.apply(snapshot, animatingDifferences: true)
  }

  @MainActor
  private func reloadFooterState() {
    guard let dataSource else { return }
    var currentSnapshot = dataSource.snapshot()

    if !currentSnapshot.sectionIdentifiers.contains(.listing) {
      return
    }

    currentSnapshot.reloadSections([.listing])

    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }

  @MainActor
  private func clearSnapshot() {
    guard let dataSource = dataSource else { return }
    let snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

extension ProductListingViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
    print("Selected: \(item.title)")
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    Task { [weak self] in
      await self?.viewModel.inputs.checkScrollPositionAndTriggerLoadIfNeeded(scrollView)
    }
  }
}

extension ProductListingViewController: FilterModalDelegate {
  func filterModalDidSave(selectedFilters: Set<EventTypeFilter>) {
    guard selectedFilters != viewModel.outputs.currentFilters else { return }

    clearSnapshot()

    viewModel.inputs.applyFilter(selectedFilters)
  }
}

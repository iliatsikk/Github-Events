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
  typealias DataSourceItem = ProductListingViewModel.DataSourceItem

  enum Section: Hashable {
    case listing
    case skeleton
    case emptyState
    case errorState
  }

  private lazy var collectionView: UICollectionView = {
    let layout = createLayout()
    return UICollectionView(frame: view.bounds, collectionViewLayout: layout)
  }()

  private lazy var scrollToTopButton: UIButton = {
    let button = UIButton(type: .system)
    var config = UIButton.Configuration.filled()
    config.title = "New Content Added"
    config.image = UIImage(systemName: "arrow.up")
    config.imagePadding = 8
    config.imagePlacement = .leading
    config.baseBackgroundColor = UIColor.secondarySystemBackground
    config.baseForegroundColor = .System.text
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(
      top: 8.0.scaledWidth, leading: 16.0.scaledWidth, bottom: 8.0.scaledWidth, trailing: 16.0.scaledWidth
    )

    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2.0.scaledWidth)
    button.layer.shadowRadius = 4
    button.layer.shadowOpacity = 0.5

    button.configuration = config
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isHidden = true
    button.alpha = 0.0
    button.addAction(UIAction { [weak self] _ in
      self?.scrollToTopButtonTapped()
    }, for: .touchUpInside)
    return button
  }()

  private var dataSource: UICollectionViewDiffableDataSource<Section, DataSourceItem>?

  private let viewModel: ProductListingViewModelType
  private var bindingTask: Task<Void, Never>? = nil

  private var isPaginating: Bool = false

  private var isScrollToTopButtonVisible = false

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

    setup()
    bind()
  }

  // MARK: - Navigation bar setup

  private func setup() {
    configureCollectionView()
    configureDataSource()

    let filterButton = UIBarButtonItem(
      image: UIImage(systemName: "line.3.horizontal.decrease"),
      style: .plain,
      target: self,
      action: #selector(filterButtonTapped)
    )

    filterButton.tintColor = UIColor.System.text

    navigationItem.rightBarButtonItem = filterButton

    view.addSubview(scrollToTopButton)
    view.bringSubviewToFront(scrollToTopButton)

    NSLayoutConstraint.activate([
      scrollToTopButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12.0.scaledWidth),
      scrollToTopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
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
    case .setContent(let items, let section, let needsReset):
      if case .listing = section, var currentSnapshot = dataSource?.snapshot() {
        currentSnapshot.deleteSections(currentSnapshot.sectionIdentifiers)
        currentSnapshot.appendSections([.listing])

        if needsReset {
          currentSnapshot.deleteItems(currentSnapshot.itemIdentifiers)
        }

        currentSnapshot.appendItems(items, toSection: .listing)
        dataSource?.apply(currentSnapshot)
        return
      }

      var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()
      snapshot.appendSections([section])
      snapshot.appendItems(items, toSection: section)

      dataSource?.apply(snapshot)
    case .updatePaginationState(let isLoading):
      isPaginating = isLoading

      if dataSource?.snapshot().sectionIdentifiers.contains(.listing) ?? false {
        reloadFooterState()
      }
    case .showScrollToTopButton:
      showScrollToTopButtonIfNeeded()
    case nil:
      print("nil action received")
    }
  }

  // MARK: - Configuration

  private func configureCollectionView() {
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
    let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
      guard let self, let dataSource = self.dataSource else { return nil }

      let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[sectionIndex]

      return switch sectionIdentifier {
      case .listing: createListingSectionLayout(layoutEnvironment: env, needsFooter: true)
      case .skeleton: createListingSectionLayout(layoutEnvironment: env, needsFooter: false)
      case .emptyState, .errorState: createStateSectionLayout(layoutEnvironment: env)
      }
    }

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .vertical
    layout.configuration = config

    return layout
  }

  private func createListingSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment, needsFooter: Bool) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5),
      heightDimension: .absolute(165.0.scaledWidth)
    )

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(165.0.scaledWidth)
    )

    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: 8.0.scaledWidth, bottom: 0, trailing: 8.0.scaledWidth
    )

    let footerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(50.0.scaledWidth)
    )

    let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: footerSize,
      elementKind: UICollectionView.elementKindSectionFooter,
      alignment: .bottom
    )
    section.boundarySupplementaryItems = needsFooter ? [sectionFooter] : []

    return section
  }

  private func createStateSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: itemSize.heightDimension
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 20.0.scaledWidth, leading: 15.0.scaledWidth, bottom: 20.0.scaledWidth, trailing: 15.0.scaledWidth
    )

    section.boundarySupplementaryItems = []

    return section
  }

  // MARK: - Data Source (Diffable + Cell Registration + Hosting Configuration)

  private func configureDataSource() {
    let itemRegistration = UICollectionView.CellRegistration<
      UICollectionViewCell, ProductListingItemContentView.Configuration
    > { cell, _, item in
      cell.contentConfiguration = UIHostingConfiguration {
        ProductListingItemContentView(configuration: item)
      }.background(.clear)
    }

    let skeletonRegistration = UICollectionView.CellRegistration<
      UICollectionViewCell, UUID
    > { cell, indexPath, _ in
      cell.contentConfiguration = UIHostingConfiguration {
        ProductListingSkeletonItemContentView()
      }.background(.clear)
    }

    let stateInfoRegistration = UICollectionView.CellRegistration<
      UICollectionViewCell, StateInfoType
    > { cell, indexPath, item in
      cell.contentConfiguration = UIHostingConfiguration {
        StateInfoContentView(stateType: item)
      }.background(.clear)
    }

    dataSource = UICollectionViewDiffableDataSource<Section, DataSourceItem>(
      collectionView: collectionView
    ) { collectionView, indexPath, item -> UICollectionViewCell? in
      return switch item {
      case .item(let config):
         collectionView.dequeueConfiguredReusableCell(
          using: itemRegistration,
          for: indexPath,
          item: config
        )
      case .skeleton(let id):
        collectionView.dequeueConfiguredReusableCell(
          using: skeletonRegistration,
          for: indexPath,
          item: id
        )
      case .stateInfo(let infoType):
        collectionView.dequeueConfiguredReusableCell(
          using: stateInfoRegistration,
          for: indexPath,
          item: infoType
        )
      }
    }

    dataSource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
      guard let self, kind == UICollectionView.elementKindSectionFooter else { return nil }

      guard let footerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: PaginationFooterView.reuseIdentifier,
        for: indexPath
      ) as? PaginationFooterView else {
        fatalError("Failed")
      }

      let sectionIdentifier = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]

      guard sectionIdentifier == .listing else { return nil }

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
  private func reloadFooterState() {
    guard let dataSource else { return }
    var currentSnapshot = dataSource.snapshot()

    if !currentSnapshot.sectionIdentifiers.contains(.listing) {
      return
    }

    currentSnapshot.reloadSections([.listing])

    dataSource.apply(currentSnapshot, animatingDifferences: false)
  }

  // MARK: - Scroll to top for newly added content

  private func scrollToTopButtonTapped() {
    guard !collectionView.visibleCells.isEmpty else { return }

    collectionView.setContentOffset(.zero, animated: true)
    hideScrollToTopButton()
  }

  private func showScrollToTopButtonIfNeeded() {
    guard !isScrollToTopButtonVisible else { return }

    guard collectionView.contentOffset.y > collectionView.bounds.height * 0.1 else { return }

    isScrollToTopButtonVisible = true
    scrollToTopButton.isHidden = false

    UIView.animate(withDuration: 0.3) {
      self.scrollToTopButton.alpha = 1.0
    }
  }

  private func hideScrollToTopButton() {
    guard isScrollToTopButtonVisible else { return }

    isScrollToTopButtonVisible = false

    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.scrollToTopButton.alpha = 0.0
    }) { [weak self] _ in
      self?.scrollToTopButton.isHidden = true
    }
  }
}

extension ProductListingViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let dataSource = dataSource else { return }

    let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]

    guard section == .listing else { return }

    guard let dataSourceItem = dataSource.itemIdentifier(for: indexPath) else { return }

    guard case .item(let item) = dataSourceItem else { return }

    guard let eventItem = viewModel.outputs.eventItems.first(where: { $0.id == item.id }) else { return }

    navigationController?.pushViewController(ProductDetailsViewController(eventItem: eventItem), animated: true)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    Task { [weak self] in
      await self?.viewModel.inputs.checkScrollPositionAndTriggerLoadIfNeeded(scrollView)
    }
  }
}

extension ProductListingViewController: FilterModalDelegate {
  func filterModalDidSave(selectedFilters: Set<EventTypeFilter>) {
    viewModel.inputs.applyFilter(selectedFilters)
  }
}

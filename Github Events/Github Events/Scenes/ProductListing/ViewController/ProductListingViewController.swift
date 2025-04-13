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

    bind()
    configureCollectionView()
    configureDataSource()
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
      applyInitialSnapshot(items)
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

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(165.0.scaledWidth)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
      group.contentInsets = NSDirectionalEdgeInsets(
        top: 0, leading: 8.0.scaledWidth, bottom: 0, trailing: 8.0.scaledWidth
      )

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 4.0.scaledWidth

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
  }

  // MARK: - Snapshot Update

  @MainActor
  private func applyInitialSnapshot(_ items: [DataSourceItem]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>()

    snapshot.appendSections([.listing])
    snapshot.appendItems(items, toSection: .listing)

    dataSource?.apply(snapshot, animatingDifferences: false)
  }
}

extension ProductListingViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
    print("Selected: \(item.title)")
  }
}

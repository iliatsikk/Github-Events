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

class ProductListingViewController: UIViewController {
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, ProductItem>?

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
    view.backgroundColor = .systemBackground
    title = "Products"

    bind()
    configureCollectionView()
    configureDataSource()
    applyInitialSnapshot()
  }

  // MARK: - Binding

  private func bind() {
    bindingTask = Task { [weak self] in
      guard let stream = self?.viewModel.outputs.stream else {
        print("Listener Task: ViewModel stream is nil.")
        return
      }

      do {
        for await action in stream {
          // Check if the task was cancelled during await
          try Task.checkCancellation()

          print("ViewController received action: \(action as Any)")
          self?.handle(action: action)
        }
        print("Listener Task: Stream finished.")
      } catch {
        print("Listener Task: Cancelled or threw error - \(error)")
      }
    }
    viewModel.inputs.viewDidLoad()
  }

  @MainActor
  private func handle(action: ViewActions?) {
    switch action {
    case .testForBinding:
      let vc = UIViewController()
      vc.view.backgroundColor = .orange

      navigationController?.pushViewController(vc, animated: true)
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
        heightDimension: .absolute(280)
      )

      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(280)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
      group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 8
      return section
    }

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .vertical
    layout.configuration = config

    return layout
  }


  // MARK: - Data Source (Diffable + Cell Registration + Hosting Configuration)

  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ProductItem> { cell, indexPath, item in
      cell.contentConfiguration = UIHostingConfiguration {
        ProductCellView(item: item)
      }

      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }

    dataSource = UICollectionViewDiffableDataSource<Section, ProductItem>(
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
  private func applyInitialSnapshot() {
    let items = ProductItem.testData()

    var snapshot = NSDiffableDataSourceSnapshot<Section, ProductItem>()

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

struct ProductCellView: View {
  let item: ProductItem

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Image(systemName: item.imageName)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .foregroundColor(.accentColor)
        .padding(.bottom, 4)
        .clipped()

      Text(item.title)
        .font(.headline)
        .lineLimit(2)

      if let description = item.description, !description.isEmpty {
        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(2)
      }

      Spacer()
    }
    .padding(8)
    .background(Color(.red))
    .cornerRadius(10)
  }
}

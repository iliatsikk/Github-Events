//
//  FilterModalViewController.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 14.04.25.
//

import Foundation
import UIKit
import Domain

@MainActor
protocol FilterModalDelegate: AnyObject {
  func filterModalDidSave(selectedFilters: Set<EventTypeFilter>)
}

@MainActor
class FilterModalViewController: UIViewController {
  weak var delegate: FilterModalDelegate?

  private let allFilters: [EventTypeFilter] = EventTypeFilter.allCases
  private var selectedFilters: Set<EventTypeFilter>
  private let initialFilters: Set<EventTypeFilter>

  private enum Section {
    case main
  }

  private lazy var tableView: UITableView = {
    let table = UITableView(frame: .zero, style: .insetGrouped)
    table.translatesAutoresizingMaskIntoConstraints = false
    table.delegate = self
    table.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
    return table
  }()

  private var dataSource: UITableViewDiffableDataSource<Section, EventTypeFilter>!

  // MARK: - Initialization

  init(initialFilters: Set<EventTypeFilter>) {
    self.initialFilters = initialFilters
    self.selectedFilters = initialFilters
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    title = "Filter"

    setupNavigationBar()
    setupTableView()
    configureDataSource()
    applySnapshot()
  }

  // MARK: - Setup

  private func setupNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = false

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(saveButtonTapped)
    )

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonTapped)
    )
  }

  private func setupTableView() {
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func configureDataSource() {
    dataSource = UITableViewDiffableDataSource<Section, EventTypeFilter>(
      tableView: tableView
    ) { [weak self] tableView, indexPath, filter in
      guard let self else { return nil }

      let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = filter.rawValue
      cell.contentConfiguration = content

      cell.accessoryType = self.selectedFilters.contains(filter) ? .checkmark : .none
      cell.selectionStyle = .none
      return cell
    }
  }

  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, EventTypeFilter>()
    snapshot.appendSections([.main])
    snapshot.appendItems(allFilters, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }

  // MARK: - Actions

  @objc private func saveButtonTapped() {
    delegate?.filterModalDidSave(selectedFilters: selectedFilters)
    dismiss(animated: true, completion: nil)
  }


  @objc private func cancelButtonTapped() {
    dismiss(animated: true, completion: nil)
  }
}

extension FilterModalViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let filter = dataSource.itemIdentifier(for: indexPath) else { return }
    if selectedFilters.contains(filter) {
      selectedFilters.remove(filter)
    } else {
      selectedFilters.insert(filter)
    }

    var snapshot = dataSource.snapshot()
    snapshot.reloadItems([filter])
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}

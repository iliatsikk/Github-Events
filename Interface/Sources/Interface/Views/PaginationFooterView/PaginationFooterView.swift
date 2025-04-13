//
//  PaginationFooterView.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import UIKit

public class PaginationFooterView: UICollectionReusableView {
  public static let reuseIdentifier = "PaginationFooterViewIdentifier"

  private let activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  public func startAnimating() {
    activityIndicator.startAnimating()
  }

  public func stopAnimating() {
    activityIndicator.stopAnimating()
  }
}

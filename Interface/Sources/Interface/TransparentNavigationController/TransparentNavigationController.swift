//
//  TransparentNavigationController.swift
//  Interface
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import UIKit

public class TransparentNavigationController: UINavigationController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupTransparentNavigationBar()
  }

  private func setupTransparentNavigationBar() {
    let appearance = UINavigationBarAppearance()

    appearance.configureWithTransparentBackground()

    let backButtonImage = UIImage(systemName: "chevron.left")?
      .withConfiguration(UIImage.SymbolConfiguration(weight: .semibold))

    appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)

    let backButtonAppearance = UIBarButtonItemAppearance()

    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
    backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
    appearance.backButtonAppearance = backButtonAppearance

    navigationBar.standardAppearance = appearance
    navigationBar.compactAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance

    navigationBar.tintColor = .systemBackground
  }

  public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    self.topViewController?.navigationItem.backButtonTitle = ""
    super.pushViewController(viewController, animated: animated)
  }
}

extension TransparentNavigationController: UINavigationControllerDelegate {}

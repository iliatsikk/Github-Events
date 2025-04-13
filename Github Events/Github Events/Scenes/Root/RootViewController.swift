//
//  ViewController.swift
//  Github Events
//
//  Created by Ilia Tsikelashvili on 10.04.25.
//

import UIKit
import Domain
import Networking

class RootViewController: UIViewController {
  let apiClient = APIClient()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    getData()
  }


  private func getData() {
    let repository: GitHubEventsRepositoring = GitHubEventsRepository(apiClient: apiClient)

    Task {
      do {
        let data = try await repository.listPublicEvents(perPage: 10, page: 1)

        let vc = UIViewController()
        vc.view.backgroundColor = .orange
        navigationController?.pushViewController(vc, animated: true)
        print("*** \(data)")
      } catch {
        print("*** \(error)")
      }
    }
  }
}

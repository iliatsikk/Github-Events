//
//  Constants.swift
//  DesignSystem
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import UIKit

public struct Constants {
  public struct Screen {
    @MainActor public static let factor = UIScreen.main.bounds.width / 440.0
    @MainActor public static let heightFactor = UIScreen.main.bounds.height / 956.0
    @MainActor public static let height = UIScreen.main.bounds.height
    @MainActor public static let width = UIScreen.main.bounds.width
  }
}

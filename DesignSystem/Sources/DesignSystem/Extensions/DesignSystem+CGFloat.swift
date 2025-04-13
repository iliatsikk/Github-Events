//
//  DesignSystem+CGFloat.swift
//  DesignSystem
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import UIKit

public extension CGFloat {
  /// Add width scale factor to self
  @MainActor var scaledWidth: CGFloat {
    (self * Constants.Screen.factor).rounded(.toNearestOrAwayFromZero)
  }

  /// Add height scale factor to self
  @MainActor var scaledHeight: CGFloat {
    self * Constants.Screen.heightFactor
  }
}

public extension Double {
  /// Add width scale factor to self
  @MainActor var scaledWidth: CGFloat {
    (self * Constants.Screen.factor).rounded(.toNearestOrAwayFromZero)
  }

  /// Add height scale factor to self
  @MainActor var scaledHeight: CGFloat {
    self * Constants.Screen.heightFactor
  }
}

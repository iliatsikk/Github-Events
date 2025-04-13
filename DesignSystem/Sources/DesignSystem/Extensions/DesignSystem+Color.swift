//
//  DesignSystem+Color.swift
//  DesignSystem
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import SwiftUI

public extension Color {
  /// System colors used in UI
  enum System {
    /// Folder name in assets catalogue
    private static let namespace = "Colors/System"

    public static let background: Color = Color("\(namespace)/background", bundle: .module)

    public static let green: Color = Color("\(namespace)/green", bundle: .module)

    public static let purple: Color = Color("\(namespace)/purple", bundle: .module)

    public static let violet: Color = Color("\(namespace)/violet", bundle: .module)

    public static let pink: Color = Color("\(namespace)/pink", bundle: .module)
  }
}

//
//  DesignSystem+UIColor.swift
//  DesignSystem
//
//  Created by Ilia Tsikelashvili on 13.04.25.
//

import UIKit

public extension UIColor {
  /// System colors used in UI
  enum System {
    /// Folder name in assets catalogue
    private static let namespace = "Colors/System"

    public static let pink: UIColor =  UIColor(named: "\(namespace)/pink", in: .module, compatibleWith: nil) ?? .clear

    public static let green: UIColor =  UIColor(named: "\(namespace)/green", in: .module, compatibleWith: nil) ?? .clear

    public static let violet: UIColor =  UIColor(named: "\(namespace)/violet", in: .module, compatibleWith: nil) ?? .clear

    public static let purple: UIColor =  UIColor(named: "\(namespace)/purple", in: .module, compatibleWith: nil) ?? .clear

    public static let background: UIColor =  UIColor(named: "\(namespace)/background", in: .module, compatibleWith: nil) ?? .clear
  }
}
